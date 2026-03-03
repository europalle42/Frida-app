import SwiftUI
import SwiftData

struct OutfitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Outfit.createdDate, order: .reverse) private var outfits: [Outfit]

    var body: some View {
        NavigationStack {
            if outfits.isEmpty {
                ContentUnavailableView {
                    Label("Ingen Outfits", systemImage: "rectangle.stack")
                } description: {
                    Text("Gaa til Styling for at bygge dit foerste outfit")
                }
            } else {
                List {
                    ForEach(outfits) { outfit in
                        OutfitRow(outfit: outfit)
                    }
                    .onDelete(perform: deleteOutfits)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Mine Outfits")
    }

    private func deleteOutfits(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(outfits[index])
        }
    }
}

// MARK: - Outfit Row

struct OutfitRow: View {
    let outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(outfit.name)
                    .font(.headline)
                Spacer()
                if let rating = outfit.rating {
                    HStack(spacing: 2) {
                        ForEach(0..<rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                ForEach(outfit.garments.prefix(6)) { garment in
                    if let image = garment.item.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Text(garment.item.category.emoji)
                            .font(.title3)
                            .frame(width: 40, height: 40)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                if outfit.itemCount > 6 {
                    Text("+\(outfit.itemCount - 6)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text(outfit.createdDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(outfit.itemCount) dele")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OutfitsView()
        .modelContainer(for: [GarmentItem.self, Outfit.self], inMemory: true)
}
