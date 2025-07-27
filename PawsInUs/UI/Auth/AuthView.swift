//
//  AuthView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI

struct AuthView: View {
    @Environment(\.injected) private var diContainer
    @State private var showSignIn = false
    @State private var showEmailSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Close button
                    HStack {
                        Button(action: {
                            // Handle close action
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Main content
                    VStack(spacing: 40) {
                        // Logo and tagline
                        VStack(spacing: 20) {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.orange)
                            
                            VStack(spacing: 8) {
                                Text("Sign in to start")
                                    .font(.system(size: 28, weight: .bold))
                                Text("finding your perfect match")
                                    .font(.system(size: 28, weight: .bold))
                            }
                            .multilineTextAlignment(.center)
                        }
                        
                        // Sign up buttons
                        VStack(spacing: 16) {
                            // KakaoTalk login (Korean login option)
                            Button(action: {
                                // Handle Kakao login
                            }) {
                                HStack {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 20))
                                    Text("Continue with Kakao")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(27)
                            }
                            
                            // Apple Sign In
                            Button(action: {
                                // Handle Apple Sign In
                            }) {
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 20))
                                    Text("Continue with Apple")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(27)
                            }
                            
                            // Email sign up
                            Button(action: {
                                showEmailSignUp = true
                            }) {
                                HStack {
                                    Image(systemName: "pawprint.fill")
                                        .font(.system(size: 20))
                                    Text("Continue with Email")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 27)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundColor(.primary)
                            }
                            
                            // Phone number sign up
                            Button(action: {
                                // Handle phone sign up
                            }) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 20))
                                    Text("Continue with Phone")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 27)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    // Footer links
                    HStack(spacing: 20) {
                        Button("Terms") {
                            // Handle terms
                        }
                        
                        Text("·")
                            .foregroundColor(.gray)
                        
                        Button("Privacy") {
                            // Handle privacy
                        }
                        
                        Text("·")
                            .foregroundColor(.gray)
                        
                        Button("Help") {
                            // Handle help
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                    
                    // Temporary bypass button for development
                    Button(action: {
                        diContainer.appState[\.userData.isAuthenticated] = true
                        diContainer.appState[\.userData.currentAdopterID] = "dev_user"
                    }) {
                        Text("Skip Sign In (Dev)")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                            .underline()
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: $showEmailSignUp) {
                EmailSignUpView()
            }
        }
    }
}

struct EmailSignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.injected) private var diContainer
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 30) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Enter your details to get started")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                // Form fields
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        TextField("Enter your name", text: $name)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        TextField("Enter your email", text: $email)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        SecureField("Create a password", text: $password)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // Sign up button
                Button(action: {
                    handleSignUp()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.orange)
                            .cornerRadius(27)
                    } else {
                        Text("Sign Up")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(27)
                    }
                }
                .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty)
                
                // Already have account
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    
                    Button("Sign In") {
                        // Handle sign in
                    }
                    .foregroundColor(.orange)
                }
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    @MainActor
    private func handleSignUp() {
        isLoading = true
        
        let authInteractor = diContainer.interactors.authInteractor
        let emailValue = email
        let passwordValue = password
        let nameValue = name
        
        Task {
            do {
                try await authInteractor.signUp(
                    email: emailValue,
                    password: passwordValue,
                    name: nameValue
                )
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AuthView()
}