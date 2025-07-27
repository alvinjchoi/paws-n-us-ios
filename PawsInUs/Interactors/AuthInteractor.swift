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
        try await supabaseClient.auth.signInWithOTP(
            email: email,
            shouldCreateUser: true
        )
    }
    
    func verifyOTP(email: String, token: String) async throws {
        let session = try await supabaseClient.auth.verifyOTP(
            email: email,
            token: token,
            type: .email
        )
        
        await MainActor.run { [appState] in
            appState[\.userData.currentAdopterID] = session.user.id.uuidString
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
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "This sign-in method is not yet implemented"
        case .profileCreationFailed:
            return "Failed to create user profile"
        }
    }
}

protocol AuthRepository {
    func createAdopterProfile(userID: String, email: String, name: String) async throws -> Adopter
    func getAdopterProfile(userID: String) async throws -> Adopter?
}