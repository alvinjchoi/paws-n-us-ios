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
    }
    
    func updateMatchStatus(matchID: String, status: MatchStatus) async throws {
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
    }
    
    func updateProfile(adopterID: String, name: String, bio: String, location: String) async throws {
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
    }
}

struct StubAuthRepository: AuthRepository {
    func createAdopterProfile(userID: String, email: String, name: String) async throws -> Adopter {
        return Adopter(
            id: userID,
            name: name,
            email: email,
            location: "San Francisco, CA"
        )
    }
    
    func getAdopterProfile(userID: String) async throws -> Adopter? {
        return MockedData.adopter
    }
}

struct StubStorageRepository: StorageRepository {
    func uploadImage(bucket: String, path: String, data: Data) async throws -> String {
        return "https://example.com/\(bucket)/\(path)"
    }
    
    func getPublicURL(bucket: String, path: String) -> String {
        return "https://example.com/\(bucket)/\(path)"
    }
    
    func deleteImage(bucket: String, path: String) async throws {
    }
    
    func listImages(bucket: String, folder: String) async throws -> [String] {
        return ["https://example.com/\(bucket)/\(folder)/image1.jpg",
                "https://example.com/\(bucket)/\(folder)/image2.jpg"]
    }
}

enum RepositoryError: Error {
    case notFound
}