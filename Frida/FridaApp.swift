import SwiftUI
import SwiftData

@main
struct FridaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [GarmentItem.self, Outfit.self, TryOnResult.self])
    }
}
