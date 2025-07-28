//
//  DIContainer.swift
//  Pawsinus
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import SwiftUI
#if canImport(SwiftData)
import SwiftData
#endif
import Supabase

struct DIContainer {

    let appState: Store<AppState>
    let interactors: Interactors
    let supabaseClient: SupabaseClient
    
    var repositories: Repositories {
        interactors.repositories
    }

    init(appState: Store<AppState> = .init(AppState()), 
         interactors: Interactors,
         supabaseClient: SupabaseClient) {
        self.appState = appState
        self.interactors = interactors
        self.supabaseClient = supabaseClient
    }

    init(appState: AppState, interactors: Interactors, 
         supabaseClient: SupabaseClient) {
        self.init(appState: Store<AppState>(appState), interactors: interactors, 
                  supabaseClient: supabaseClient)
    }
}

extension DIContainer {
    struct Repositories {
        let dogsRepository: DogsRepository
        let matchesRepository: MatchesRepository
        let matchingRepository: MatchingRepository
        let adopterRepository: AdopterRepository
        let authRepository: AuthRepository
        let storageRepository: StorageRepository
        let images: ImagesWebRepository
        let pushToken: PushTokenWebRepository
        let articleRepository: ArticleRepository
        let messagesRepository: MessagesRepository
        let visitsRepository: VisitsRepository
        let rescuerRepository: RescuerRepository
    }
    struct Interactors {
        let appState: Store<AppState>
        let repositories: Repositories
        
        init(appState: Store<AppState>, repositories: Repositories) {
            self.appState = appState
            self.repositories = repositories
        }

        static var stub: Self {
            #if DEBUG
            return .init(appState: Store(AppState()),
                  repositories: Repositories(
                      dogsRepository: StubDogsRepository(),
                      matchesRepository: StubMatchesRepository(),
                      matchingRepository: StubMatchingRepository(),
                      adopterRepository: StubAdopterRepository(),
                      authRepository: StubAuthRepository(),
                      storageRepository: StubStorageRepository(),
                      images: StubImagesRepository(),
                      pushToken: StubPushTokenRepository(),
                      articleRepository: SanityArticleRepository(),
                      messagesRepository: StubMessagesRepository(),
                      visitsRepository: StubVisitsRepository(),
                      rescuerRepository: StubRescuerRepository()
                  ))
            #else
            fatalError("Stub interactors should only be used in DEBUG mode")
            #endif
        }
    }
}

extension EnvironmentValues {
    @Entry var injected: DIContainer = {
        #if DEBUG
        return DIContainer(
            appState: AppState(), 
            interactors: .stub,
            supabaseClient: SupabaseConfig.client
        )
        #else
        fatalError("DIContainer must be injected via .inject() modifier")
        #endif
    }()
}

extension View {
    func inject(_ container: DIContainer) -> some View {
        return self
            .environment(\.injected, container)
    }
}
