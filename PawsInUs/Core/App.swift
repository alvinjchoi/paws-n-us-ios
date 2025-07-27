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
    
    var body: some View {
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
            
            Text("Profile View")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(AppState.Tab.profile)
        }
        .onAppear {
            print("🌟 RootView appeared")
        }
    }
}
