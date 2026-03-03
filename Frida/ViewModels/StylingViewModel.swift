import SwiftUI

@MainActor
class StylingViewModel: ObservableObject {
    @Published var selectedGarments: [OutfitGarment] = []
    @Published var outfitName = ""
    @Published var showingSaveDialog = false

    func addGarment(_ item: GarmentItem) {
        let layer = item.category.defaultLayer

        // Replace existing garment on same layer
        selectedGarments.removeAll { $0.layer == layer }

        let garment = OutfitGarment(
            item: item,
            state: GarmentState.default(for: item.category),
            layer: layer
        )
        selectedGarments.append(garment)
        selectedGarments.sort { $0.layer < $1.layer }
    }

    func removeGarment(at layer: GarmentLayer) {
        selectedGarments.removeAll { $0.layer == layer }
    }

    func clearAll() {
        selectedGarments.removeAll()
    }

    var canSave: Bool {
        !selectedGarments.isEmpty
    }

    var layerSummary: String {
        selectedGarments.map { $0.item.category.emoji }.joined(separator: " ")
    }
}
