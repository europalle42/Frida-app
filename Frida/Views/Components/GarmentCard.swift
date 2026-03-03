import SwiftUI

struct GarmentCard: View {
    let item: GarmentItem

    var body: some View {
        VStack(spacing: 0) {
            // Image area
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
                    .frame(height: 180)

                if let image = item.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    Text(item.category.emoji)
                        .font(.system(size: 56))
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                HStack {
                    Text(item.category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if item.timesWorn > 0 {
                        Label("\(item.timesWorn)", systemImage: "arrow.clockwise")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}

#Preview {
    GarmentCard(item: GarmentItem(name: "Hvid Skjorte", category: .tops))
        .frame(width: 180)
        .padding()
}
