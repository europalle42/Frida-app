import Foundation
import UIKit

enum TryOnError: LocalizedError {
    case invalidImage
    case networkError(String)
    case apiError(String)
    case noResult

    var errorDescription: String? {
        switch self {
        case .invalidImage: "Ugyldigt billede"
        case .networkError(let msg): "Netvaerksfejl: \(msg)"
        case .apiError(let msg): "API fejl: \(msg)"
        case .noResult: "Intet resultat modtaget"
        }
    }
}

/// Service for virtual try-on API calls.
/// Supports Hugging Face Spaces (Kolors-VTON, IDM-VTON) and Google Gemini.
actor TryOnAPIService {

    // MARK: - Public

    func generateTryOn(
        personImage: Data,
        garmentImage: Data,
        provider: TryOnProvider
    ) async throws -> Data {
        switch provider {
        case .kolorsVTON:
            return try await callHuggingFaceSpace(
                spaceId: "Kwai-Kolors/Kolors-Virtual-Try-On",
                personImage: personImage,
                garmentImage: garmentImage
            )
        case .idmVTON:
            return try await callHuggingFaceSpace(
                spaceId: "yisol/IDM-VTON",
                personImage: personImage,
                garmentImage: garmentImage
            )
        case .gemini:
            return try await callGeminiAPI(
                personImage: personImage,
                garmentImage: garmentImage
            )
        }
    }

    // MARK: - Hugging Face Spaces (Gradio API)

    private func callHuggingFaceSpace(
        spaceId: String,
        personImage: Data,
        garmentImage: Data
    ) async throws -> Data {
        let baseURL = "https://\(spaceId.replacingOccurrences(of: "/", with: "-").lowercased()).hf.space"

        // Step 1: Upload images
        let personPath = try await uploadToHF(baseURL: baseURL, imageData: personImage, filename: "person.jpg")
        let garmentPath = try await uploadToHF(baseURL: baseURL, imageData: garmentImage, filename: "garment.jpg")

        // Step 2: Call predict endpoint
        let predictURL = URL(string: "\(baseURL)/api/predict")!
        var request = URLRequest(url: predictURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        let payload: [String: Any] = [
            "data": [
                ["path": personPath],
                ["path": garmentPath]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TryOnError.apiError("HF Space returned error")
        }

        // Step 3: Parse result and download image
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataArray = json["data"] as? [[String: Any]],
              let firstResult = dataArray.first,
              let resultPath = firstResult["path"] as? String else {
            throw TryOnError.noResult
        }

        return try await downloadFromHF(baseURL: baseURL, path: resultPath)
    }

    private func uploadToHF(baseURL: String, imageData: Data, filename: String) async throws -> String {
        let uploadURL = URL(string: "\(baseURL)/upload")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let paths = try JSONSerialization.jsonObject(with: data) as? [String],
              let path = paths.first else {
            throw TryOnError.apiError("Upload failed")
        }

        return path
    }

    private func downloadFromHF(baseURL: String, path: String) async throws -> Data {
        let fileURL = URL(string: "\(baseURL)/file=\(path)")!
        let (data, _) = try await URLSession.shared.data(from: fileURL)
        return data
    }

    // MARK: - Google Gemini API

    private func callGeminiAPI(
        personImage: Data,
        garmentImage: Data
    ) async throws -> Data {
        // Gemini API endpoint for image generation
        // Requires API key stored in app config
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
              !apiKey.isEmpty else {
            throw TryOnError.apiError("Gemini API key ikke konfigureret. Tilfoej GEMINI_API_KEY i Info.plist")
        }

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        let personBase64 = personImage.base64EncodedString()
        let garmentBase64 = garmentImage.base64EncodedString()

        let payload: [String: Any] = [
            "contents": [[
                "parts": [
                    ["text": "Generate a virtual try-on image. Take the person from the first image and show them wearing the garment from the second image. Make it look realistic and natural."],
                    ["inline_data": ["mime_type": "image/jpeg", "data": personBase64]],
                    ["inline_data": ["mime_type": "image/jpeg", "data": garmentBase64]]
                ]
            ]],
            "generationConfig": [
                "responseModalities": ["IMAGE", "TEXT"]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TryOnError.apiError("Gemini API error")
        }

        // Parse response for image data
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
}
