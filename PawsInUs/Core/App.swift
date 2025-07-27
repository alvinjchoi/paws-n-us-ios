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
                .onOpenURL { url in
                    Task {
                        do {
                            try await SupabaseConfig.client.auth.session(from: url)
                        } catch {
                        }
                    }
                }
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
        AppView()
            .onAppear {
            }
    }
}
