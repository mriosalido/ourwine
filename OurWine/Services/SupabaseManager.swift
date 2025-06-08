import Foundation
import Supabase

@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()

    @Published private(set) var client: SupabaseClient
    @Published var session: Session?

    static let winePhotosBucket = Config.shared.supabaseBucket

    private init() {
        self.client = SupabaseClient(
            supabaseURL: Config.shared.supabaseURL,
            supabaseKey: Config.shared.supabaseKey
        )
        listenForAuthState()
    }
    
    private func listenForAuthState() {
        Task {
            for await (event, session) in client.auth.authStateChanges {
                self.session = session
                print("Auth event: \(event)")
            }
        }
    }
} 