import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            WardrobeView()
                .tabItem {
                    Label("Garderobe", systemImage: "tshirt")
                }
                .tag(0)

            StylingView()
                .tabItem {
                    Label("Styling", systemImage: "wand.and.stars")
                }
                .tag(1)

            OutfitsView()
                .tabItem {
                    Label("Outfits", systemImage: "rectangle.stack")
                }
                .tag(2)

            TryOnView()
                .tabItem {
                    Label("Try-On", systemImage: "person.crop.rectangle")
                }
                .tag(3)
        }
        .tint(.purple)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [GarmentItem.self, Outfit.self, TryOnResult.self], inMemory: true)
}
