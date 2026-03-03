import SwiftUI
import SwiftData
import PhotosUI

struct TryOnView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var garments: [GarmentItem]
    @StateObject private var viewModel = TryOnViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.state {
                case .idle, .selectingPerson:
                    personSelectionView
                case .selectingGarment:
                    garmentSelectionView
                case .processing:
                    processingView
                case .result:
                    resultView
                case .error(let message):
                    errorView(message)
                }
            }
            .navigationTitle("Virtual Try-On")
            .toolbar {
                if viewModel.state != .idle {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Start forfra") {
                            viewModel.reset()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 1: Select Person Photo

    private var personSelectionView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.crop.rectangle")
                .font(.system(size: 60))
                .foregroundStyle(.purple.opacity(0.6))

            Text("Tag et billede af dig selv\neller vaelg fra bibliotek")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                PhotosPicker(selection: $viewModel.personPhotoItem, matching: .images) {
                    Label("Vaelg fra Fotos", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .onChange(of: viewModel.personPhotoItem) {
                    Task { await viewModel.loadPersonPhoto() }
                }

                Button {
                    viewModel.showingCamera = true
                } label: {
                    Label("Tag Billede", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            // Provider picker
            providerPicker
                .padding()
        }
        .fullScreenCover(isPresented: $viewModel.showingCamera) {
            CameraView { imageData in
                viewModel.personImageData = imageData
                viewModel.state = .selectingGarment
            }
        }
    }

    // MARK: - Step 2: Select Garment

    private var garmentSelectionView: some View {
        VStack(spacing: 16) {
            // Person preview
            if let personImage = viewModel.personImage {
                Image(uiImage: personImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.purple, lineWidth: 2)
                    )
            }

            Text("Vaelg toej at proeve")
                .font(.headline)

            if garments.isEmpty {
                ContentUnavailableView {
                    Label("Ingen toej", systemImage: "tshirt")
                } description: {
                    Text("Tilfoej toej i Garderobe-tabben foerst")
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(garments) { garment in
                            GarmentPickerCard(
                                garment: garment,
                                isSelected: viewModel.selectedGarment?.id == garment.id
                            ) {
                                viewModel.selectGarment(garment)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Button {
                Task { await viewModel.startTryOn() }
            } label: {
                Label("Start Try-On", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedGarment != nil ? Color.purple : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(viewModel.selectedGarment == nil)
            .padding(.horizontal)
        }
    }

    // MARK: - Processing

    private var processingView: some View {
        VStack(spacing: 24) {
            Spacer()

            ProgressView(value: viewModel.progress) {
                Text("Genererer try-on...")
                    .font(.headline)
            }
            .progressViewStyle(.linear)
            .tint(.purple)
            .padding(.horizontal, 40)

            Text("AI behandler dit billede med \(viewModel.selectedProvider.rawValue)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    // MARK: - Result

    private var resultView: some View {
        VStack(spacing: 16) {
            if let resultImage = viewModel.resultImage {
                Image(uiImage: resultImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 8)
                    .padding()
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.saveResult(context: modelContext)
                } label: {
                    Label("Gem", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)

                ShareLink(
                    item: Image(uiImage: viewModel.resultImage ?? UIImage()),
                    preview: SharePreview("Frida Try-On", image: Image(uiImage: viewModel.resultImage ?? UIImage()))
                ) {
                    Label("Del", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            Button("Proev andet toej") {
                viewModel.state = .selectingGarment
                viewModel.resultImageData = nil
                viewModel.selectedGarment = nil
            }
            .padding(.bottom)
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Fejl", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Proev igen") {
                viewModel.state = .selectingGarment
            }
        }
    }

    // MARK: - Provider Picker

    private var providerPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI Provider")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Provider", selection: $viewModel.selectedProvider) {
                ForEach(TryOnProvider.allCases) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - Garment Picker Card

struct GarmentPickerCard: View {
    let garment: GarmentItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if let image = garment.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Text(garment.category.emoji)
                        .font(.system(size: 36))
                        .frame(width: 80, height: 80)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Text(garment.name)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
            .padding(6)
            .background(isSelected ? Color.purple.opacity(0.15) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    TryOnView()
        .modelContainer(for: [GarmentItem.self, TryOnResult.self], inMemory: true)
}
