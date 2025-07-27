//
//  CountriesApp.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import SwiftUI

@main
struct MainApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            appDelegate.rootView
        }
    }
}

extension AppEnvironment {
    var rootView: some View {
        RootView()
            .modifier(RootViewAppearance())
            .modelContainer(modelContainer)
            .inject(diContainer)
    }
}

struct RootView: View {
    @Environment(\.injected) private var diContainer
    @State private var isAuthenticated: Bool = false
    
    var body: some View {
        VStack {
            if ProcessInfo.processInfo.isRunningTests {
                Text("Running unit tests")
            } else {
                if isAuthenticated {
                    NavigationStack {
                        TabView(selection: diContainer.appState.binding(for: \.routing.selectedTab)) {
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
                    }
                } else {
                    AuthView()
                }
                if diContainer.modelContainer.isStub {
                    Text("⚠️ There is an issue with local database")
                        .font(.caption2)
                }
            }
        }
        .onReceive(diContainer.appState.updates(for: \.userData.isAuthenticated)) { authenticated in
            withAnimation {
                isAuthenticated = authenticated
            }
        }
        .onAppear {
            isAuthenticated = diContainer.appState.value.userData.isAuthenticated
        }
    }

}
