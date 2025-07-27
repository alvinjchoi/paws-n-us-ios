//
//  AppState.swift
//  Pawsinus
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

struct AppState: Equatable {
    var routing = ViewRouting()
    var system = System()
    var permissions = Permissions()
    var userData = UserData()
}

extension AppState {
    struct ViewRouting: Equatable {
        var selectedTab: Tab = .discover
        var dogDetails = DogDetails.Routing()
        var likes = Likes.Routing()
    }
    
    enum Tab: Equatable {
        case discover
        case likes
        case profile
    }
}

extension AppState {
    struct UserData: Equatable {
        var currentAdopterID: String? = "550e8400-e29b-41d4-a716-446655440100" // TODO: Remove this test ID
        var isAuthenticated: Bool = true // TODO: Set to false for production
        var likedDogIDs: Set<String> = []
        var dislikedDogIDs: Set<String> = []
        var matchedDogIDs: Set<String> = []
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = true // Start as active
        var keyboardHeight: CGFloat = 0
    }
}

extension AppState {
    struct Permissions: Equatable {
        var push: Permission.Status = .unknown
    }

    static func permissionKeyPath(for permission: Permission) -> WritableKeyPath<AppState, Permission.Status> {
        let pathToPermissions = \AppState.permissions
        switch permission {
        case .pushNotifications:
            return pathToPermissions.appending(path: \.push)
        }
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.routing == rhs.routing
        && lhs.system == rhs.system
        && lhs.permissions == rhs.permissions
        && lhs.userData == rhs.userData
}
