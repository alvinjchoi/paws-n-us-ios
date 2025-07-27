//
//  DIContainer.swift
//  Pawsinus
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import SwiftUI
import SwiftData
import Supabase

struct DIContainer {

    let appState: Store<AppState>
    let interactors: Interactors
    let modelContainer: ModelContainer
    let supabaseClient: SupabaseClient

    init(appState: Store<AppState> = .init(AppState()), 
         interactors: Interactors,
         modelContainer: ModelContainer,
         supabaseClient: SupabaseClient) {
        self.appState = appState
        self.interactors = interactors
        self.modelContainer = modelContainer
        self.supabaseClient = supabaseClient
    }

    init(appState: AppState, interactors: Interactors, modelContainer: ModelContainer, supabaseClient: SupabaseClient) {
        self.init(appState: Store<AppState>(appState), interactors: interactors, modelContainer: modelContainer, supabaseClient: supabaseClient)
    }
}

extension DIContainer {
    struct Repositories {
        let dogsRepository: DogsRepository
        let matchesRepository: MatchesRepository
        let matchingRepository: MatchingRepository
        let adopterRepository: AdopterRepository
        let authRepository: AuthRepository
        let images: ImagesWebRepository
        let pushToken: PushTokenWebRepository
    }
    struct Interactors {
        let appState: Store<AppState>
        let repositories: Repositories
        
        init(appState: Store<AppState>, repositories: Repositories) {
            self.appState = appState
            self.repositories = repositories
        }

        static var stub: Self {
            .init(appState: Store(AppState()),
                  repositories: Repositories(
                      dogsRepository: StubDogsRepository(),
                      matchesRepository: StubMatchesRepository(),
                      matchingRepository: StubMatchingRepository(),
                      adopterRepository: StubAdopterRepository(),
                      authRepository: StubAuthRepository(),
                      images: StubImagesRepository(),
                      pushToken: StubPushTokenRepository()
                  ))
        }
    }
}

extension EnvironmentValues {
    @Entry var injected: DIContainer = DIContainer(
        appState: AppState(), 
        interactors: .stub,
        modelContainer: .stub,
        supabaseClient: SupabaseConfig.client
    )
}

extension View {
    func inject(_ container: DIContainer) -> some View {
        return self
            .environment(\.injected, container)
    }
}
