import SwiftUI
import Supabase
import SwiftData

struct HomeView: View {
    var body: some View {
        TabView {
            TastingListView()
                .tabItem {
                    Label("Cata", systemImage: "flame")
                }
            
            WineListView()
                .tabItem {
                    Label("Vinos", systemImage: "wineglass")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
