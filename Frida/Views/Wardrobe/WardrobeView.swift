import SwiftUI
import SwiftData
import PhotosUI

struct WardrobeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GarmentItem.createdDate, order: .reverse) private var items: [GarmentItem]
    @StateObject private var viewModel = WardrobeViewModel()

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                CategoryFilterBar(selected: $viewModel.selectedCategory)

                // Grid
                ScrollView {
                    if viewModel.filteredItems(items).isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredItems(items)) { item in
                                GarmentCard(item: item)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.deleteGarment(item, context: modelContext)
                                        } label: {
                                            Label("Slet", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Min Garderobe")
            .searchable(text: $viewModel.searchText, prompt: "Soeg i garderobe...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingAddSheet = true
                    } label: {
                        Label("Tilfoej", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                AddGarmentView(viewModel: viewModel)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Ingen toej", systemImage: "tshirt")
        } description: {
            Text("Tryk + for at tilfoeje dit foerste toejstykke")
        }
        .padding(.top, 60)
    }
}

// MARK: - Add Garment Sheet

struct AddGarmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WardrobeViewModel
    @State private var name = ""
    @State private var category: GarmentCategory = .tops

    var body: some View {
        NavigationStack {
            Form {
                Section("Detaljer") {
                    TextField("Navn paa toej", text: $name)
                    Picker("Kategori", selection: $category) {
                        ForEach(GarmentCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.systemImage)
                                .tag(cat)
                        }
                    }
                }

                Section("Billede") {
                    PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                        if let data = viewModel.selectedImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Label("Vaelg billede", systemImage: "photo.on.rectangle.angled")
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .onChange(of: viewModel.selectedPhotoItem) {
                        Task { await viewModel.loadImage() }
                    }
                }
            }
            .navigationTitle("Nyt Toej")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuller") {
                        viewModel.resetForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gem") {
                        viewModel.addGarment(name: name, category: category, context: modelContext)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    WardrobeView()
        .modelContainer(for: GarmentItem.self, inMemory: true)
}
