//
//  AppView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI
import Supabase

struct AppView: View {
    @Environment(\.injected) private var diContainer
    @State private var isAuthenticated = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                TabView {
                    SwipeView()
                        .tabItem {
                            Label("Discover", systemImage: "pawprint.fill")
                        }
                        .tag(AppState.Tab.discover)
                    
                    LikesView()
                        .tabItem {
                            Label("Likes", systemImage: "heart.fill")
                        }
                        .tag(AppState.Tab.likes)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .tag(AppState.Tab.profile)
                }
            } else {
                AuthView()
            }
        }
        .task {
            // Listen for auth state changes
            for await state in diContainer.supabaseClient.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                    isAuthenticated = state.session != nil
                    
                    // Update app state
                    await MainActor.run {
                        diContainer.appState[\.userData.isAuthenticated] = state.session != nil
                        if let session = state.session {
                            diContainer.appState[\.userData.currentAdopterID] = session.user.id.uuidString
                        } else {
                            diContainer.appState[\.userData.currentAdopterID] = nil
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AppView()
        .inject(DIContainer(
            appState: AppState(),
            interactors: .stub,
            modelContainer: .stub,
            supabaseClient: SupabaseConfig.client
        ))
}