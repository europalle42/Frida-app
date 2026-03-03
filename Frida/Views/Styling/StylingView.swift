import SwiftUI
import SwiftData

struct StylingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [GarmentItem]
    @StateObject private var viewModel = StylingViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Outfit preview area
                outfitPreview
                    .frame(maxHeight: .infinity)

                Divider()

                // Garment selector
                garmentSelector
                    .frame(height: 140)

                // Action buttons
                actionButtons
                    .padding()
            }
            .navigationTitle("Style Outfit")
            .alert("Gem Outfit", isPresented: $viewModel.showingSaveDialog) {
                TextField("Outfit navn", text: $viewModel.outfitName)
                Button("Annuller", role: .cancel) {
                    viewModel.outfitName = ""
                }
                Button("Gem") {
                    saveOutfit()
                }
            } message: {
                Text("Giv dit outfit et navn")
            }
        }
    }

    // MARK: - Outfit Preview

    private var outfitPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))

            if viewModel.selectedGarments.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.quaternary)
                    Text("Vaelg toej nedenfor\nfor at bygge dit outfit")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.tertiary)

                    ForEach(viewModel.selectedGarments) { garment in
                        HStack {
                            Text(garment.item.category.emoji)
                            Text(garment.item.name)
                                .font(.subheadline)
                            Spacer()
                            Text(garment.layer.displayName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Button {
                                viewModel.removeGarment(at: garment.layer)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
    }

    // MARK: - Garment Selector

    private var garmentSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items) { item in
                    Button {
                        viewModel.addGarment(item)
                    } label: {
                        VStack(spacing: 6) {
                            if let image = item.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Text(item.category.emoji)
                                    .font(.system(size: 36))
                                    .frame(width: 70, height: 70)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Text(item.name)
                                .font(.caption2)
                                .lineLimit(1)
                                .foregroundStyle(.primary)
                        }
                        .frame(width: 80)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGray6).opacity(0.5))
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.clearAll()
            } label: {
                Label("Ryd", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.selectedGarments.isEmpty)

            Button {
                viewModel.showingSaveDialog = true
            } label: {
                Label("Gem Outfit", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .disabled(!viewModel.canSave)
        }
    }

    private func saveOutfit() {
        let outfit = Outfit(name: viewModel.outfitName, garments: viewModel.selectedGarments)
        modelContext.insert(outfit)
        viewModel.outfitName = ""
        viewModel.clearAll()
    }
}

#Preview {
    StylingView()
        .modelContainer(for: [GarmentItem.self, Outfit.self], inMemory: true)
}
