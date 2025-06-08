import SwiftUI
import SwiftData

@main
struct OurWineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Wine.self, WinePhoto.self, Tasting.self, TastingGroup.self, TastingPhoto.self, User.self])
        }
    }
}
