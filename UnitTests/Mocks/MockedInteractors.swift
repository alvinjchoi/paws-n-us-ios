//
//  MockedInteractors.swift
//  UnitTests
//
//  Created by Alexey Naumov on 07.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Testing
import SwiftUI
import ViewInspector
@testable import CountriesSwiftUI

extension DIContainer.Interactors {
    static func mocked(
        appState: Store<AppState> = Store(AppState()),
        repositories: DIContainer.Repositories = mockRepositories()
    ) -> DIContainer.Interactors {
        return self.init(
            appState: appState,
            repositories: repositories
        )
    }
    
    private static func mockRepositories() -> DIContainer.Repositories {
        return DIContainer.Repositories(
            dogsRepository: MockedDogsRepository(),
            matchesRepository: MockedMatchesRepository(),
            matchingRepository: MockedMatchingRepository(),
            adopterRepository: MockedAdopterRepository(),
            images: MockedImagesWebRepository(),
            pushToken: MockedPushTokenWebRepository()
        )
    }
}

// MARK: - Mocked Repositories

struct MockedDogsRepository: Mock, DogsRepository {
    enum Action: Equatable {
        case getDogs
        case getDog(id: String)
    }
    
    let actions: MockActions<Action>
    var dogsResponse: Result<[Dog], Error> = .success(MockedData.dogs)
    var dogResponse: Result<Dog, Error> = .success(MockedData.dogs[0])
    
    init(expected: [Action] = []) {
        self.actions = .init(expected: expected)
    }
    
    func getDogs() async throws -> [Dog] {
        register(.getDogs)
        return try dogsResponse.get()
    }
    
    func getDog(by id: String) async throws -> Dog {
        register(.getDog(id: id))
        return try dogResponse.get()
    }
}

struct MockedMatchesRepository: Mock, MatchesRepository {
    enum Action: Equatable {
        case getMatches(adopterID: String)
        case sendMessage(matchID: String)
        case updateMatchStatus(matchID: String, status: MatchStatus)
    }
    
    let actions: MockActions<Action>
    var matchesResponse: Result<[Match], Error> = .success(MockedData.matches)
    
    init(expected: [Action] = []) {
        self.actions = .init(expected: expected)
    }
    
    func getMatches(for adopterID: String) async throws -> [Match] {
        register(.getMatches(adopterID: adopterID))
        return try matchesResponse.get()
    }
    
    func sendMessage(matchID: String, message: Message) async throws {
        register(.sendMessage(matchID: matchID))
    }
    
    func updateMatchStatus(matchID: String, status: MatchStatus) async throws {
        register(.updateMatchStatus(matchID: matchID, status: status))
    }
}

struct MockedMatchingRepository: Mock, MatchingRepository {
    enum Action: Equatable {
        case checkForMatch(adopterID: String, dogID: String)
    }
    
    let actions: MockActions<Action>
    var matchResponse: Result<Match?, Error> = .success(nil)
    
    init(expected: [Action] = []) {
        self.actions = .init(expected: expected)
    }
    
    func checkForMatch(adopterID: String, dogID: String) async throws -> Match? {
        register(.checkForMatch(adopterID: adopterID, dogID: dogID))
        return try matchResponse.get()
    }
}

struct MockedAdopterRepository: Mock, AdopterRepository {
    enum Action: Equatable {
        case getAdopter(id: String)
        case updatePreferences(adopterID: String)
        case updateProfile(adopterID: String)
    }
    
    let actions: MockActions<Action>
    var adopterResponse: Result<Adopter?, Error> = .success(MockedData.adopter)
    
    init(expected: [Action] = []) {
        self.actions = .init(expected: expected)
    }
    
    func getAdopter(by id: String) async throws -> Adopter? {
        register(.getAdopter(id: id))
        return try adopterResponse.get()
    }
    
    func updatePreferences(adopterID: String, preferences: AdopterPreferences) async throws {
        register(.updatePreferences(adopterID: adopterID))
    }
    
    func updateProfile(adopterID: String, name: String, bio: String, location: String) async throws {
        register(.updateProfile(adopterID: adopterID))
    }
}

struct MockedImagesWebRepository: ImagesWebRepository {
    let session: URLSession = .shared
    let baseURL: String = ""
    
    func loadImage(url: URL) async throws -> UIImage {
        return UIImage(systemName: "photo")!
    }
}

struct MockedPushTokenWebRepository: PushTokenWebRepository {
    let session: URLSession = .shared
    let baseURL: String = ""
    
    func register(devicePushToken: Data) async throws {
        // Mock implementation
    }
}

// MARK: - MockedUserPermissionsInteractor

final class MockedUserPermissionsInteractor: Mock, UserPermissionsInteractor {
    
    enum Action: Equatable {
        case resolveStatus(Permission)
        case request(Permission)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func resolveStatus(for permission: Permission) {
        register(.resolveStatus(permission))
    }
    
    func request(permission: Permission) {
        register(.request(permission))
    }
}