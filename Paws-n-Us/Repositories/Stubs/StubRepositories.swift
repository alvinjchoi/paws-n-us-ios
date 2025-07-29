//
//  StubRepositories.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import UIKit
import Combine

#if DEBUG

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
    
    func getDogsByRescuer(rescuerID: String) async throws -> [Dog] {
        return MockedData.dogs.filter { $0.rescuerID == rescuerID }
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

struct StubMessagesRepository: MessagesRepository {
    func createMessage(_ message: MessageDBDTO) async throws {
        // Stub implementation
    }
    
    func getMessages(for recipientID: String) async throws -> [MessageDBDTO] {
        return []
    }
    
    func markMessageAsRead(_ messageID: String) async throws {
        // Stub implementation
    }
}

struct StubVisitsRepository: VisitsRepository {
    func createVisit(_ request: CreateVisitRequest) async throws -> Visit {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return Visit(
            id: UUID(),
            rescuerId: request.rescuerId,
            adopterId: request.adopterId,
            animalId: request.animalId,
            visitType: request.visitType,
            scheduledDate: request.scheduledDate,
            durationMinutes: request.durationMinutes,
            location: request.location,
            status: .scheduled,
            rescuerNotes: nil,
            adopterNotes: request.adopterNotes,
            outcome: nil,
            requirements: request.requirements,
            preparationNotes: nil,
            followUpRequired: false,
            followUpDate: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func getVisitsForRescuer(_ rescuerId: UUID) async throws -> [Visit] {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        return []
    }
    
    func getVisitsForAdopter(_ adopterId: String) async throws -> [Visit] {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        return []
    }
    
    func getVisitsForAnimal(_ animalId: UUID) async throws -> [Visit] {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        return []
    }
    
    func updateVisitStatus(_ visitId: UUID, status: VisitStatus) async throws -> Visit {
        throw NSError(domain: "StubRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Stub implementation"])
    }
    
    func cancelVisit(_ visitId: UUID, reason: String?) async throws -> Visit {
        throw NSError(domain: "StubRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Stub implementation"])
    }
    
    func getVisitsByDate(_ rescuerId: UUID, date: Date) async throws -> [Visit] {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        return []
    }
    
    func getVisits(_ rescuerId: UUID) async throws -> [Visit] {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        return []
    }
}

struct StubRescuerRepository: RescuerRepository {
    func getRescuerByUserID(_ userID: String) async throws -> RescuerDTO? {
        // Return a test rescuer for development
        return RescuerDTO(
            id: "test-rescuer-id",
            userID: userID,
            organizationName: "테스트 보호소",
            registrationNumber: "TEST-001",
            verificationStatus: "verified",
            specialties: ["개", "고양이"],
            capacity: 10,
            currentCount: 3,
            location: "서울시 강남구",
            contactPhone: "02-1234-5678",
            contactEmail: "test@rescuer.com",
            bio: "테스트 구조자입니다",
            websiteURL: nil,
            socialMedia: [:],
            earningsTotal: 0.0,
            rating: 4.5,
            reviewCount: 10,
            isActive: true,
            createdAt: "2025-01-01T00:00:00Z",
            updatedAt: "2025-01-01T00:00:00Z"
        )
    }
}

enum RepositoryError: Error {
    case notFound
}

#endif