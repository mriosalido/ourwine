import SwiftUI
import Supabase

struct LoginView: View {
    private let client = SupabaseManager.shared.client
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text(isSigningUp ? "Registrarse" : "Iniciar Sesión")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            SecureField("Contraseña", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)

            if isLoading {
                ProgressView()
            } else {
                Button(action: handleAction) {
                    Text(isSigningUp ? "Registrarse" : "Iniciar Sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            
            Button(action: {
                isSigningUp.toggle()
                errorMessage = nil
            }) {
                Text(isSigningUp ? "¿Ya tienes cuenta? Inicia Sesión" : "¿No tienes cuenta? Regístrate")
            }
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    private func handleAction() {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                if isSigningUp {
                    _ = try await client.auth.signUp(email: email, password: password)
                } else {
                    _ = try await client.auth.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    LoginView()
} 