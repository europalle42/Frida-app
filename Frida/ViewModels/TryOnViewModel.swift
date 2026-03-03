import SwiftUI
import SwiftData
import PhotosUI

enum TryOnState: Equatable {
    case idle
    case selectingPerson
    case selectingGarment
    case processing
    case result
    case error(String)
}

enum TryOnProvider: String, CaseIterable, Identifiable {
    case kolorsVTON = "Kolors-VTON"
    case idmVTON = "IDM-VTON"
    case gemini = "Gemini"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .kolorsVTON: "Hugging Face (gratis)"
        case .idmVTON: "Hugging Face (gratis)"
        case .gemini: "Google Gemini API"
        }
    }
}

@MainActor
class TryOnViewModel: ObservableObject {
    @Published var state: TryOnState = .idle
    @Published var personImageData: Data?
    @Published var garmentImageData: Data?
    @Published var resultImageData: Data?
    @Published var selectedGarment: GarmentItem?
    @Published var selectedProvider: TryOnProvider = .kolorsVTON
    @Published var personPhotoItem: PhotosPickerItem?
    @Published var showingCamera = false
    @Published var progress: Double = 0

    var personImage: UIImage? {
        guard let data = personImageData else { return nil }
        return UIImage(data: data)
    }

    var resultImage: UIImage? {
        guard let data = resultImageData else { return nil }
        return UIImage(data: data)
    }

    func loadPersonPhoto() async {
        guard let item = personPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            personImageData = data
            state = .selectingGarment
        }
    }

    func selectGarment(_ garment: GarmentItem) {
        selectedGarment = garment
        garmentImageData = garment.imageData
    }

    func startTryOn() async {
        guard personImageData != nil, garmentImageData != nil else { return }
        state = .processing
        progress = 0

        let service = TryOnAPIService()

        do {
            // Simulate progress updates
            for step in stride(from: 0.1, through: 0.8, by: 0.1) {
                try await Task.sleep(for: .milliseconds(300))
                progress = step
            }

            let result = try await service.generateTryOn(
                personImage: personImageData!,
                garmentImage: garmentImageData!,
                provider: selectedProvider
            )

            progress = 1.0
            resultImageData = result
            state = .result
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func saveResult(context: ModelContext) {
        let result = TryOnResult(
            personImageData: personImageData,
            garmentImageData: garmentImageData,
            resultImageData: resultImageData,
            garmentName: selectedGarment?.name ?? "Ukendt",
            provider: selectedProvider.rawValue
        )
        context.insert(result)
    }

    func reset() {
        state = .idle
        personImageData = nil
        garmentImageData = nil
        resultImageData = nil
        selectedGarment = nil
        personPhotoItem = nil
        progress = 0
    }
}
