import SwiftUI

struct CategoryFilterBar: View {
    @Binding var selected: GarmentCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(title: "Alle", emoji: nil, isSelected: selected == nil) {
                    selected = nil
                }

                ForEach(GarmentCategory.allCases) { category in
                    FilterChip(
                        title: category.displayName,
                        emoji: category.emoji,
                        isSelected: selected == category
                    ) {
                        selected = category
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
}

struct FilterChip: View {
    let title: String
    let emoji: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let emoji {
                    Text(emoji)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? Color.purple : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    CategoryFilterBar(selected: .constant(.tops))
}
