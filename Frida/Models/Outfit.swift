import Foundation
import SwiftData

// MARK: - GarmentState

struct GarmentState: Codable {
    var position: GarmentPosition
    var openness: Double // 0.0 = closed, 1.0 = open
    var rolled: Bool

    static func `default`(for category: GarmentCategory) -> GarmentState {
        GarmentState(position: .standard, openness: 0.0, rolled: false)
    }
}

enum GarmentPosition: String, Codable {
    case standard = "Standard"
    case inTucked = "I bukser"
    case outTucked = "Ude"
}

// MARK: - OutfitGarment (transient helper)

struct OutfitGarment: Identifiable {
    let id = UUID()
    var item: GarmentItem
    var state: GarmentState
    var layer: GarmentLayer
}

// MARK: - Outfit Model

@Model
final class Outfit {
    var id: UUID
    var name: String
    var garmentItems: [GarmentItem]
    var garmentStates: [String: Data] // UUID string : encoded GarmentState
    var garmentLayers: [String: Int]  // UUID string : layer rawValue
    var createdDate: Date
    var tags: [String]
    var rating: Int?
    @Attribute(.externalStorage) var previewImageData: Data?

    init(name: String, garments: [OutfitGarment] = []) {
        self.id = UUID()
        self.name = name
        self.garmentItems = []
        self.garmentStates = [:]
        self.garmentLayers = [:]
        self.createdDate = Date()
        self.tags = []

        for og in garments {
            self.garmentItems.append(og.item)
            if let encoded = try? JSONEncoder().encode(og.state) {
                self.garmentStates[og.item.id.uuidString] = encoded
            }
            self.garmentLayers[og.item.id.uuidString] = og.layer.rawValue
        }
    }

    var garments: [OutfitGarment] {
        garmentItems.compactMap { item in
            guard let stateData = garmentStates[item.id.uuidString],
                  let state = try? JSONDecoder().decode(GarmentState.self, from: stateData),
                  let layerValue = garmentLayers[item.id.uuidString],
                  let layer = GarmentLayer(rawValue: layerValue) else {
                return nil
            }
            return OutfitGarment(item: item, state: state, layer: layer)
        }.sorted { $0.layer < $1.layer }
    }

    var itemCount: Int { garmentItems.count }
}
