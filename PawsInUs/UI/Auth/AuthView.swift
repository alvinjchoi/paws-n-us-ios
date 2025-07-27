//
//  AuthView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI
import Supabase

struct AuthView: View {
    @Environment(\.injected) private var diContainer
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var result: Result<Void, Error>?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Button("Sign in with Magic Link") {
                        signInButtonTapped()
                    }
                    .disabled(email.isEmpty || isLoading)
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                if let result {
                    Section {
                        switch result {
                        case .success:
                            Text("Check your email inbox for the magic link.")
                                .foregroundStyle(.green)
                        case .failure(let error):
                            Text(error.localizedDescription)
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                // Temporary bypass for development
                Section {
                    Button(action: {
                        diContainer.appState[\.userData.isAuthenticated] = true
                        diContainer.appState[\.userData.currentAdopterID] = "dev_user"
                        dismiss()
                    }) {
                        Text("Skip Sign In (Dev)")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onOpenURL { url in
                Task {
                    do {
                        try await diContainer.supabaseClient.auth.session(from: url)
                        dismiss()
                    } catch {
                        self.result = .failure(error)
                    }
                }
            }
        }
    }
    
    private func signInButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await diContainer.supabaseClient.auth.signInWithOTP(
                    email: email,
                    redirectTo: URL(string: "io.pawsinus://login-callback")
                )
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    AuthView()
        .inject(DIContainer(
            appState: AppState(),
            interactors: .stub,
            modelContainer: .stub,
            supabaseClient: SupabaseConfig.client
        ))
}