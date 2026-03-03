import Foundation
import SwiftData
import SwiftUI

@Model
final class TryOnResult {
    var id: UUID
    var createdDate: Date
    @Attribute(.externalStorage) var personImageData: Data?
    @Attribute(.externalStorage) var garmentImageData: Data?
    @Attribute(.externalStorage) var resultImageData: Data?
    var garmentName: String
    var provider: String // "catvton", "hf_kolors", "hf_idm", "gemini"
    var isFavorite: Bool

    init(
        personImageData: Data?,
        garmentImageData: Data?,
        resultImageData: Data?,
        garmentName: String,
        provider: String
    ) {
        self.id = UUID()
        self.createdDate = Date()
        self.personImageData = personImageData
        self.garmentImageData = garmentImageData
        self.resultImageData = resultImageData
        self.garmentName = garmentName
        self.provider = provider
        self.isFavorite = false
    }

    var resultImage: Image? {
        guard let resultImageData, let uiImage = UIImage(data: resultImageData) else { return nil }
        return Image(uiImage: uiImage)
    }

    var personImage: Image? {
        guard let personImageData, let uiImage = UIImage(data: personImageData) else { return nil }
        return Image(uiImage: uiImage)
    }
}
