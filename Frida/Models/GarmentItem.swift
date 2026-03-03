import Foundation
import SwiftData
import SwiftUI

// MARK: - Enums

enum GarmentCategory: String, Codable, CaseIterable, Identifiable {
    case tops = "Tops"
    case bukser = "Bukser"
    case nederdele = "Nederdele"
    case kjoler = "Kjoler"
    case jakker = "Jakker"
    case sko = "Sko"
    case accessories = "Accessories"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .tops: "👕"
        case .bukser: "👖"
        case .nederdele: "👗"
        case .kjoler: "👗"
        case .jakker: "🧥"
        case .sko: "👟"
        case .accessories: "👜"
        }
    }

    var displayName: String { rawValue }

    var defaultLayer: GarmentLayer {
        switch self {
        case .tops: .top
        case .bukser, .nederdele: .bottom
        case .kjoler: .top
        case .jakker: .outerwear
        case .sko: .shoes
        case .accessories: .accessories
        }
    }

    var systemImage: String {
        switch self {
        case .tops: "tshirt"
        case .bukser: "figure.stand"
        case .nederdele: "figure.dress.line.vertical.figure"
        case .kjoler: "figure.dress.line.vertical.figure"
        case .jakker: "cloud.snow"
        case .sko: "shoe"
        case .accessories: "bag"
        }
    }
}

enum GarmentLayer: Int, Codable, Comparable, CaseIterable {
    case base = 0
    case bottom = 1
    case top = 2
    case midLayer = 3
    case outerwear = 4
    case accessories = 5
    case shoes = 6

    var zIndex: CGFloat { CGFloat(rawValue * 100) }

    var displayName: String {
        switch self {
        case .base: "Base"
        case .bottom: "Underdel"
        case .top: "Overdel"
        case .midLayer: "Mellemlag"
        case .outerwear: "Ydertoej"
        case .accessories: "Accessories"
        case .shoes: "Sko"
        }
    }

    static func < (lhs: GarmentLayer, rhs: GarmentLayer) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - GarmentItem Model

@Model
final class GarmentItem {
    var id: UUID
    var name: String
    var category: GarmentCategory
    @Attribute(.externalStorage) var imageData: Data?
    var dominantColorHex: String?
    var tags: [String]
    var timesWorn: Int
    var lastWorn: Date?
    var createdDate: Date

    init(name: String, category: GarmentCategory, imageData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.imageData = imageData
        self.tags = []
        self.timesWorn = 0
        self.createdDate = Date()
    }

    var image: Image? {
        guard let imageData, let uiImage = UIImage(data: imageData) else { return nil }
        return Image(uiImage: uiImage)
    }

    var dominantColor: Color {
        guard let hex = dominantColorHex else { return .gray }
        return Color(hex: hex)
    }
}
