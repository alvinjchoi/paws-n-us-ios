//
//  AuthInteractor.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import SwiftUI
import Supabase

protocol AuthInteractor: Sendable {
    func signUp(email: String, password: String, name: String) async throws
    func signIn(email: String, password: String) async throws
    func signInWithOTP(email: String) async throws
    func verifyOTP(email: String, token: String) async throws
    func signOut() async throws
    func getCurrentUser() async throws -> User?
    func signInWithApple() async throws
    func signInWithKakao() async throws
}

extension DIContainer.Interactors {
    var authInteractor: AuthInteractor {
        RealAuthInteractor(
            appState: appState,
            authRepository: repositories.authRepository,
            supabaseClient: SupabaseConfig.client
        )
    }
}

final class RealAuthInteractor: AuthInteractor, @unchecked Sendable {
    let appState: Store<AppState>
    let authRepository: AuthRepository
    let supabaseClient: SupabaseClient
    
    init(appState: Store<AppState>, authRepository: AuthRepository, supabaseClient: SupabaseClient) {
        self.appState = appState
        self.authRepository = authRepository
        self.supabaseClient = supabaseClient
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        // Sign up with Supabase
        let authResponse = try await supabaseClient.auth.signUp(
            email: email,
            password: password,
            data: ["name": AnyJSON(name)]
        )
        
        let user = authResponse.user
        // Create adopter profile
        let adopter = try await authRepository.createAdopterProfile(
            userID: user.id.uuidString,
            email: email,
            name: name
        )
        
        await MainActor.run { [appState] in
            appState[\.userData.currentAdopterID] = adopter.id
            appState[\.userData.isAuthenticated] = true
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let session = try await supabaseClient.auth.signIn(
            email: email,
            password: password
        )
        
        await MainActor.run { [appState] in
            appState[\.userData.currentAdopterID] = session.user.id.uuidString
            appState[\.userData.isAuthenticated] = true
        }
    }
    
    func signInWithOTP(email: String) async throws {
        // Send magic link to email
        // Note: Supabase sends magic links for email auth by default
        // To display it as an OTP code, modify the email template in Supabase dashboard
        try await supabaseClient.auth.signInWithOTP(
            email: email
        )
    }
    
    func verifyOTP(email: String, token: String) async throws {
        // For email magic links displayed as OTP codes
        // We need to construct and process the magic link URL
        let tokenHash = token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? token
        let typeParam = "email"
        
        // Create the verification URL that would normally be in the magic link
        var components = URLComponents()
        components.scheme = "io.pawsinus"  // Your app's URL scheme
        components.host = "login-callback"
        components.queryItems = [
            URLQueryItem(name: "token_hash", value: tokenHash),
            URLQueryItem(name: "type", value: typeParam)
        ]
        
        guard let url = components.url else {
            throw AuthError.invalidToken
        }
        
        // Process the magic link URL
        try await supabaseClient.auth.session(from: url)
        
        // Get the authenticated user
        guard let user = supabaseClient.auth.currentUser else {
            throw AuthError.invalidToken
        }
        
        // Update app state
        await MainActor.run { [appState] in
            appState[\.userData.currentAdopterID] = user.id.uuidString
            appState[\.userData.isAuthenticated] = true
        }
    }
    
    func signOut() async throws {
        try await supabaseClient.auth.signOut()
        
        await MainActor.run { [appState] in
            appState[\.userData.isAuthenticated] = false
            appState[\.userData.currentAdopterID] = nil
            appState[\.userData.likedDogIDs] = []
            appState[\.userData.dislikedDogIDs] = []
            appState[\.userData.matchedDogIDs] = []
        }
    }
    
    func getCurrentUser() async throws -> User? {
        return supabaseClient.auth.currentSession?.user
    }
    
    func signInWithApple() async throws {
        // TODO: Implement Apple Sign In with Supabase
        throw AuthError.notImplemented
    }
    
    func signInWithKakao() async throws {
        // TODO: Implement Kakao Sign In with Supabase
        throw AuthError.notImplemented
    }
}

enum AuthError: LocalizedError {
    case notImplemented
    case profileCreationFailed
    case invalidToken
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "This sign-in method is not yet implemented"
        case .profileCreationFailed:
            return "Failed to create user profile"
        case .invalidToken:
            return "Invalid verification token"
        }
    }
}

protocol AuthRepository {
    func createAdopterProfile(userID: String, email: String, name: String) async throws -> Adopter
    func getAdopterProfile(userID: String) async throws -> Adopter?
}