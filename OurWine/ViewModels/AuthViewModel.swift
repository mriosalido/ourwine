import Foundation
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var session: Session?
    
    // Form state
    @Published var email = ""
    @Published var password = ""
    @Published var isSigningUp = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var authTask: Task<Void, Never>?
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
        authTask = Task {
            for await (_, session) in self.supabaseClient.auth.authStateChanges {
                self.session = session
            }
        }
    }
    
    func handleAction() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if isSigningUp {
                try await supabaseClient.auth.signUp(email: email, password: password)
            } else {
                try await supabaseClient.auth.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    deinit {
        authTask?.cancel()
    }
} 