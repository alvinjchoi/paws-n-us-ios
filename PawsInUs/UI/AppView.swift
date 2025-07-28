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
    @State private var selectedTab: AppState.Tab = .discover
        
    var body: some View {
        TabView(selection: $selectedTab) {
            MagazineView()
                .tabItem {
                    Label("Magazine", systemImage: "book.fill")
                }
                .tag(AppState.Tab.magazine)
            
            SwipeView()
                .tabItem {
                    Label("Discover", systemImage: "pawprint.fill")
                }
                .tag(AppState.Tab.discover)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(AppState.Tab.profile)
        }
        .task {
            // Listen for auth state changes
            for await state in diContainer.supabaseClient.auth.authStateChanges {
                print("AppView: Auth state event: \(state.event), session exists: \(state.session != nil)")
                if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                    // Update app state
                    await MainActor.run {
                        let isAuthenticated = state.session != nil
                        print("AppView: Setting isAuthenticated to: \(isAuthenticated)")
                        diContainer.appState[\.userData.isAuthenticated] = isAuthenticated
                        if let session = state.session {
                            diContainer.appState[\.userData.currentAdopterID] = session.user.id.uuidString
                            print("AppView: User ID set to: \(session.user.id.uuidString)")
                        } else {
                            diContainer.appState[\.userData.currentAdopterID] = nil
                            diContainer.appState[\.userData.likedDogIDs] = []
                            diContainer.appState[\.userData.dislikedDogIDs] = []
                            diContainer.appState[\.userData.matchedDogIDs] = []
                        }
                    }
                }
            }
        }
        .onReceive(diContainer.appState.updates(for: \.routing.selectedTab)) { tab in
            selectedTab = tab
        }
        .onChange(of: selectedTab) { newTab in
            diContainer.appState[\.routing.selectedTab] = newTab
        }
        .onAppear {
            // Sync initial tab from app state
            selectedTab = diContainer.appState[\.routing.selectedTab]
        }
    }
}

#Preview {
    AppView()
        .inject(DIContainer(
            appState: AppState(),
            interactors: .stub,
            supabaseClient: SupabaseConfig.client
        ))
}