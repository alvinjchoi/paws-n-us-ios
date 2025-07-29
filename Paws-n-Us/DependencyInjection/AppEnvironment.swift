//
//  AppEnvironment.swift
//  Pawsinus
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import UIKit
#if canImport(SwiftData)
import SwiftData
#endif
import Supabase

@MainActor
struct AppEnvironment {
    let isRunningTests: Bool
    let diContainer: DIContainer
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {

    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        /*
         To see the deep linking in action:

         1. Launch the app in iOS 13.4 simulator (or newer)
         2. Subscribe on Push Notifications with "Allow Push" button
         3. Minimize the app
         4. Drag & drop "push_with_deeplink.apns" into the Simulator window
         5. Tap on the push notification

         Alternatively, just copy the code below before the "return" and launch:

            DispatchQueue.main.async {
                deepLinksHandler.open(deepLink: .showCountryFlag(alpha3Code: "AFG"))
            }
        */
        let session = configuredURLSession()
        let supabaseClient = SupabaseConfig.client
        
        let repositories = configuredRepositories(session: session, modelContainer: nil, supabaseClient: supabaseClient)
        let interactors = DIContainer.Interactors(appState: appState, repositories: repositories)
        let diContainer = DIContainer(appState: appState, interactors: interactors, supabaseClient: supabaseClient)
        let deepLinksHandler = RealDeepLinksHandler(container: diContainer)
        let pushNotificationsHandler = RealPushNotificationsHandler(deepLinksHandler: deepLinksHandler)
        let systemEventsHandler = RealSystemEventsHandler(
            container: diContainer,
            deepLinksHandler: deepLinksHandler,
            pushNotificationsHandler: pushNotificationsHandler,
            pushTokenWebRepository: repositories.pushToken)
        return AppEnvironment(
            isRunningTests: ProcessInfo.processInfo.isRunningTests,
            diContainer: diContainer,
            systemEventsHandler: systemEventsHandler)
    }

    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }

    private static func configuredRepositories(session: URLSession, modelContainer: Any?, supabaseClient: SupabaseClient) -> DIContainer.Repositories {
        #if DEBUG
        if ProcessInfo.processInfo.isRunningTests {
            return DIContainer.Repositories(
                dogsRepository: StubDogsRepository(),
                matchesRepository: StubMatchesRepository(),
                matchingRepository: StubMatchingRepository(),
                adopterRepository: StubAdopterRepository(),
                authRepository: StubAuthRepository(),
                storageRepository: StubStorageRepository(),
                images: RealImagesWebRepository(session: session),
                pushToken: RealPushTokenWebRepository(session: session),
                articleRepository: SanityArticleRepository(),
                messagesRepository: StubMessagesRepository(),
                visitsRepository: SupabaseVisitsRepository(client: supabaseClient),
                rescuerRepository: StubRescuerRepository(),
                animalsRepository: StubAnimalsRepository()
            )
        }
        #endif
        
        return DIContainer.Repositories(
            dogsRepository: LocalDogsRepository(),
            matchesRepository: SupabaseMatchesRepository(client: supabaseClient),
            matchingRepository: SupabaseMatchingRepository(client: supabaseClient),
            adopterRepository: SupabaseAdopterRepository(client: supabaseClient),
            authRepository: SupabaseAuthRepository(client: supabaseClient),
            storageRepository: SupabaseStorageRepository(client: supabaseClient),
            images: RealImagesWebRepository(session: session),
            pushToken: RealPushTokenWebRepository(session: session),
            articleRepository: SanityArticleRepository(),
            messagesRepository: SupabaseMessagesRepository(client: supabaseClient),
            visitsRepository: SupabaseVisitsRepository(client: supabaseClient),
            rescuerRepository: SupabaseRescuerRepository(client: supabaseClient),
            animalsRepository: APIAnimalsRepository()
        )
    }

    #if canImport(SwiftData)
    @available(iOS 17.0, *)
    private static func configuredModelContainer() -> ModelContainer {
        do {
            let container = try ModelContainer.appModelContainer()
            return container
        } catch {
            return ModelContainer.stub
        }
    }
    #endif

}
