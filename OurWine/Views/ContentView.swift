import SwiftUI
import Supabase
import SwiftData

struct ContentView: View {
    @State private var session: Session?
    @Environment(\.modelContext) private var modelContext
    
    private let supabaseService: SupabaseService
    
    init() {
        let client = SupabaseManager.shared.client
        self.supabaseService = SupabaseService(supabaseClient: client)
    }
    
    var body: some View {
        Group {
            if session == nil {
                LoginView()
            } else {
                HomeView()
                    .environmentObject(
                        WineListViewModel(
                            wineService: supabaseService,
                            storageService: supabaseService,
                            modelContext: modelContext
                        )
                    )
            }
        }
        .onReceive(SupabaseManager.shared.$session) { newSession in
            self.session = newSession
        }
    }
}
