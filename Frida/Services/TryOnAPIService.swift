import Foundation
import UIKit

enum TryOnError: LocalizedError {
    case invalidImage
    case networkError(String)
    case apiError(String)
    case noResult
    case spaceOffline(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage: "Ugyldigt billede"
        case .networkError(let msg): "Netvaerksfejl: \(msg)"
        case .apiError(let msg): "API fejl: \(msg)"
        case .noResult: "Intet resultat modtaget fra AI"
        case .spaceOffline(let name): "\(name) er offline. Proev en anden provider."
        }
    }
}

/// Service for virtual try-on via free Hugging Face Spaces (Gradio REST API).
/// No API key required — all endpoints are free and public.
///
/// Working providers (March 2026):
/// - IDM-VTON (yisol) — Zero GPU, free, high quality
/// - Kolors-VTON (Kwai-Kolors) — free, good quality
/// - Gemini — requires free API key from Google AI Studio
actor TryOnAPIService {

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 180  // Try-on can take up to 3 min on free GPU
        config.timeoutIntervalForResource = 300
        return URLSession(configuration: config)
    }()

    // MARK: - Public

    func generateTryOn(
        personImage: Data,
        garmentImage: Data,
        provider: TryOnProvider
    ) async throws -> Data {
        // Compress images for faster upload (max 1024px)
        let person = compressImage(personImage, maxDimension: 1024)
        let garment = compressImage(garmentImage, maxDimension: 768)

        switch provider {
        case .kolorsVTON:
            return try await callGradioSpace(
                baseURL: "https://kwai-kolors-kolors-virtual-try-on.hf.space",
                personImage: person,
                garmentImage: garment,
                spaceName: "Kolors-VTON"
            )
        case .idmVTON:
            return try await callGradioSpace(
                baseURL: "https://yisol-idm-vton.hf.space",
                personImage: person,
                garmentImage: garment,
                spaceName: "IDM-VTON"
            )
        case .gemini:
            return try await callGeminiAPI(
                personImage: person,
                garmentImage: garment
            )
        }
    }

    // MARK: - Gradio REST API (works with any HF Space)

    /// Calls a Gradio Space using the standard REST API.
    /// Flow: upload files → call /api/predict → download result
    private func callGradioSpace(
        baseURL: String,
        personImage: Data,
        garmentImage: Data,
        spaceName: String
    ) async throws -> Data {

        // Step 1: Check if space is awake
        let infoURL = URL(string: "\(baseURL)/info")!
        do {
            let (_, infoResponse) = try await session.data(from: infoURL)
            if let http = infoResponse as? HTTPURLResponse, http.statusCode != 200 {
                throw TryOnError.spaceOffline(spaceName)
            }
        } catch is URLError {
            throw TryOnError.spaceOffline(spaceName)
        }

        // Step 2: Upload images via /upload endpoint
        let personPath = try await uploadFile(baseURL: baseURL, data: personImage, filename: "person.jpg")
        let garmentPath = try await uploadFile(baseURL: baseURL, data: garmentImage, filename: "garment.jpg")

        // Step 3: Call /api/predict with file paths
        let predictURL = URL(string: "\(baseURL)/api/predict")!
        var request = URLRequest(url: predictURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Gradio expects {"data": [...]} format
        // Most VTON spaces take: [person_image, garment_image, ...]
        let payload: [String: Any] = [
            "data": [
                ["path": personPath, "orig_name": "person.jpg", "size": personImage.count, "mime_type": "image/jpeg"],
                ["path": garmentPath, "orig_name": "garment.jpg", "size": garmentImage.count, "mime_type": "image/jpeg"],
                "Virtual Try-on result",  // Description/category (some spaces need this)
                true,                      // Auto-generate mask
                true,                      // Auto-crop
                30,                        // Denoising steps
                42                         // Seed
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw TryOnError.networkError("Intet svar fra server")
        }

        // If 503 — space is still waking up (Zero GPU)
        if http.statusCode == 503 {
            // Wait and retry once
            try await Task.sleep(for: .seconds(15))
            let (retryData, retryResponse) = try await session.data(for: request)
            guard let retryHttp = retryResponse as? HTTPURLResponse, retryHttp.statusCode == 200 else {
                throw TryOnError.spaceOffline(spaceName)
            }
            return try await parseGradioResult(retryData, baseURL: baseURL)
        }

        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw TryOnError.apiError("\(spaceName): HTTP \(http.statusCode) — \(body.prefix(200))")
        }

        return try await parseGradioResult(data, baseURL: baseURL)
    }

    /// Parse Gradio predict response and download result image
    private func parseGradioResult(_ data: Data, baseURL: String) async throws -> Data {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataArray = json["data"] as? [Any] else {
            throw TryOnError.noResult
        }

        // Result can be nested differently depending on the Space
        // Try common formats: [{"path": "..."}, ...] or [{"url": "..."}, ...]
        for item in dataArray {
            if let dict = item as? [String: Any] {
                // Format 1: {"path": "/file=tmp/xxx.png"}
                if let path = dict["path"] as? String {
                    return try await downloadFile(baseURL: baseURL, path: path)
                }
                // Format 2: {"url": "https://..."}
                if let urlStr = dict["url"] as? String, let url = URL(string: urlStr) {
                    let (imageData, _) = try await session.data(from: url)
                    return imageData
                }
            }
            // Format 3: Nested array [[{...}]]
            if let arr = item as? [[String: Any]], let first = arr.first, let path = first["path"] as? String {
                return try await downloadFile(baseURL: baseURL, path: path)
            }
        }

        throw TryOnError.noResult
    }

    // MARK: - File Upload/Download

    private func uploadFile(baseURL: String, data: Data, filename: String) async throws -> String {
        let uploadURL = URL(string: "\(baseURL)/upload")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n")
        request.httpBody = body

        let (responseData, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw TryOnError.apiError("Upload fejlede for \(filename)")
        }

        // Response is typically ["/path/to/file"]
        if let paths = try JSONSerialization.jsonObject(with: responseData) as? [String],
           let path = paths.first {
            return path
        }

        throw TryOnError.apiError("Kunne ikke parse upload-svar")
    }

    private func downloadFile(baseURL: String, path: String) async throws -> Data {
        // Path can be "/file=tmp/xxx.png" or just "tmp/xxx.png"
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let fileURLStr = cleanPath.starts(with: "http") ? cleanPath : "\(baseURL)/\(cleanPath)"

        guard let fileURL = URL(string: fileURLStr) else {
            // Try alternate format
            let altURL = URL(string: "\(baseURL)/file=\(path)")!
            let (data, _) = try await session.data(from: altURL)
            return data
        }

        let (data, _) = try await session.data(from: fileURL)
        return data
    }

    // MARK: - Google Gemini API (free tier: 15 req/min)

    private func callGeminiAPI(
        personImage: Data,
        garmentImage: Data
    ) async throws -> Data {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
              !apiKey.isEmpty else {
            throw TryOnError.apiError(
                "Gemini API key mangler. Faa en gratis paa aistudio.google.com og tilfoej som GEMINI_API_KEY i Info.plist"
            )
        }

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let personBase64 = personImage.base64EncodedString()
        let garmentBase64 = garmentImage.base64EncodedString()

        let payload: [String: Any] = [
            "contents": [[
                "parts": [
                    ["text": "Generate a photorealistic virtual try-on image. Take the person from the first image and realistically show them wearing the garment from the second image. Maintain the person's pose, body shape, and background. Only change their clothing."],
                    ["inline_data": ["mime_type": "image/jpeg", "data": personBase64]],
                    ["inline_data": ["mime_type": "image/jpeg", "data": garmentBase64]]
                ]
            ]],
            "generationConfig": [
                "responseModalities": ["IMAGE", "TEXT"]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw TryOnError.apiError("Gemini: HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0) — \(body.prefix(200))")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            throw TryOnError.noResult
        }

        for part in parts {
            if let inlineData = part["inlineData"] as? [String: Any],
               let base64 = inlineData["data"] as? String,
               let imageData = Data(base64Encoded: base64) {
                return imageData
            }
        }

        throw TryOnError.noResult
    }

    // MARK: - Helpers

    private func compressImage(_ data: Data, maxDimension: CGFloat) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let scale = min(maxDimension / max(size.width, size.height), 1.0)
        if scale >= 1.0 { return image.jpegData(compressionQuality: 0.85) ?? data }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: 0.85) ?? data
    }
}

// MARK: - Data extension for multipart

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
