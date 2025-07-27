//
//  AuthInteractor.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import SwiftUI

protocol AuthInteractor {
    func signUp(email: String, password: String, name: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut()
    func signInWithApple() async throws
    func signInWithKakao() async throws
}

extension DIContainer.Interactors {
    var authInteractor: AuthInteractor {
        RealAuthInteractor(
            appState: appState,
            authRepository: repositories.authRepository
        )
    }
}

struct RealAuthInteractor: AuthInteractor {
    let appState: Store<AppState>
    let authRepository: AuthRepository
    
    func signUp(email: String, password: String, name: String) async throws {
        // Create new adopter account
        let adopter = Adopter(
            name: name,
            email: email,
            location: "Unknown"
        )
        
        // In a real app, this would call an API
        appState[\.userData.currentAdopterID] = adopter.id
        appState[\.userData.isAuthenticated] = true
    }
    
    func signIn(email: String, password: String) async throws {
        // In a real app, this would validate credentials
        appState[\.userData.currentAdopterID] = "user1"
        appState[\.userData.isAuthenticated] = true
    }
    
    func signOut() {
        appState[\.userData.isAuthenticated] = false
        appState[\.userData.currentAdopterID] = nil
        appState[\.userData.likedDogIDs] = []
        appState[\.userData.dislikedDogIDs] = []
        appState[\.userData.matchedDogIDs] = []
    }
    
    func signInWithApple() async throws {
        // Implement Apple Sign In
        appState[\.userData.currentAdopterID] = "apple_user"
        appState[\.userData.isAuthenticated] = true
    }
    
    func signInWithKakao() async throws {
        // Implement Kakao Sign In
        appState[\.userData.currentAdopterID] = "kakao_user"
        appState[\.userData.isAuthenticated] = true
    }
}

protocol AuthRepository {
    func signUp(email: String, password: String, name: String) async throws -> Adopter
    func signIn(email: String, password: String) async throws -> Adopter
}