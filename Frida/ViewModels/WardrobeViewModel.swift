import SwiftUI
import SwiftData
import PhotosUI

@MainActor
class WardrobeViewModel: ObservableObject {
    @Published var selectedCategory: GarmentCategory?
    @Published var searchText = ""
    @Published var showingAddSheet = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedImageData: Data?

    func filteredItems(_ items: [GarmentItem]) -> [GarmentItem] {
        var result = items

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result.sorted { $0.createdDate > $1.createdDate }
    }

    func loadImage() async {
        guard let item = selectedPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            selectedImageData = data
        }
    }

    func addGarment(name: String, category: GarmentCategory, context: ModelContext) {
        let item = GarmentItem(name: name, category: category, imageData: selectedImageData)
        context.insert(item)
        resetForm()
    }

    func deleteGarment(_ item: GarmentItem, context: ModelContext) {
        context.delete(item)
    }

    func resetForm() {
        selectedPhotoItem = nil
        selectedImageData = nil
        showingAddSheet = false
    }
}
