//
//  StubRepositories.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import UIKit

struct StubDogsRepository: DogsRepository {
    func getDogs() async throws -> [Dog] {
        return MockedData.dogs
    }
    
    func getDog(by id: String) async throws -> Dog {
        guard let dog = MockedData.dogs.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        return dog
    }
}

struct StubMatchesRepository: MatchesRepository {
    func getMatches(for adopterID: String) async throws -> [Match] {
        return MockedData.matches.filter { $0.adopterID == adopterID }
    }
    
    func sendMessage(matchID: String, message: Message) async throws {
        print("Stub: Message sent to match \(matchID)")
    }
    
    func updateMatchStatus(matchID: String, status: MatchStatus) async throws {
        print("Stub: Updated match \(matchID) status to \(status)")
    }
}

struct StubMatchingRepository: MatchingRepository {
    func checkForMatch(adopterID: String, dogID: String) async throws -> Match? {
        return Match(dogID: dogID, adopterID: adopterID, shelterID: "shelter1")
    }
}

struct StubAdopterRepository: AdopterRepository {
    func getAdopter(by id: String) async throws -> Adopter? {
        return MockedData.adopter
    }
    
    func updatePreferences(adopterID: String, preferences: AdopterPreferences) async throws {
        print("Stub: Updated preferences for adopter \(adopterID)")
    }
    
    func updateProfile(adopterID: String, name: String, bio: String, location: String) async throws {
        print("Stub: Updated profile for adopter \(adopterID)")
    }
}

struct StubImagesRepository: ImagesWebRepository {
    let session: URLSession = .shared
    let baseURL: String = ""
    
    func loadImage(url: URL) async throws -> UIImage {
        return UIImage(systemName: "photo")!
    }
}

struct StubPushTokenRepository: PushTokenWebRepository {
    let session: URLSession = .shared
    let baseURL: String = ""
    
    func register(devicePushToken: Data) async throws {
        print("Stub: Push token registered")
    }
}

struct StubAuthRepository: AuthRepository {
    func signUp(email: String, password: String, name: String) async throws -> Adopter {
        return Adopter(
            name: name,
            email: email,
            location: "San Francisco, CA"
        )
    }
    
    func signIn(email: String, password: String) async throws -> Adopter {
        return MockedData.adopter
    }
}

enum RepositoryError: Error {
    case notFound
}