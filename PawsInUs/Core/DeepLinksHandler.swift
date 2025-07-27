//
//  DeepLinksHandler.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Foundation

enum DeepLink: Equatable {
    
    case showDog(dogID: String)
    case showMatch(matchID: String)
    case showProfile

    init?(url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.host == "pawsinus.app"
            else { return nil }
        
        let pathComponents = components.path.components(separatedBy: "/").filter { !$0.isEmpty }
        guard let firstPath = pathComponents.first else { return nil }
        
        switch firstPath {
        case "dog":
            if let dogID = components.queryItems?.first(where: { $0.name == "id" })?.value {
                self = .showDog(dogID: dogID)
                return
            }
        case "match":
            if let matchID = components.queryItems?.first(where: { $0.name == "id" })?.value {
                self = .showMatch(matchID: matchID)
                return
            }
        case "profile":
            self = .showProfile
            return
        default:
            break
        }
        return nil
    }
}

// MARK: - DeepLinksHandler

@MainActor
protocol DeepLinksHandler: Sendable {
    @MainActor func open(deepLink: DeepLink)
}

struct RealDeepLinksHandler: DeepLinksHandler {
    
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func open(deepLink: DeepLink) {
        switch deepLink {
        case .showDog:
            // Navigate to dog details
            container.appState.bulkUpdate {
                $0.routing.selectedTab = .discover
                // TODO: Implement navigation to specific dog
            }
        case .showMatch:
            // Navigate to likes tab
            container.appState.bulkUpdate {
                $0.routing.selectedTab = .likes
                // TODO: Implement navigation to specific liked dog
            }
        case .showProfile:
            // Navigate to profile tab
            container.appState.bulkUpdate {
                $0.routing.selectedTab = .profile
            }
        }
    }
}
