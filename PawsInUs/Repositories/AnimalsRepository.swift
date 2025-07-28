//
//  AnimalsRepository.swift
//  PawsInUs
//
//  Created by Assistant on 1/28/25.
//

import Foundation
import UIKit

// MARK: - Protocol
protocol AnimalsRepository: Sendable {
    func createAnimal(_ request: CreateAnimalRequest) async throws -> CreatedAnimal
    func uploadImages(_ images: [UIImage], for animalId: String) async throws -> [String]
    func getAnimals(rescuerId: String?, species: String?, limit: Int, offset: Int) async throws -> AnimalsResponse
}

// MARK: - Response Models
struct CreatedAnimal: Codable {
    let id: String
    let name: String
    let species: String
    let imageUrls: [String]
    let helpNeeded: [String]
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, species, message
        case imageUrls = "imageUrls"
        case helpNeeded = "helpNeeded"
    }
}

struct AnimalsResponse: Codable {
    let animals: [AnimalListItem]
    let total: Int
}

struct AnimalListItem: Codable {
    let id: String
    let name: String
    let breed: String?
    let age: Int
    let gender: String
    let location: String
    let imageUrls: [String]?
    let isAvailable: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, breed, age, gender, location
        case imageUrls = "image_urls"
        case isAvailable = "is_available"
        case createdAt = "created_at"
    }
}

// MARK: - API Implementation
final class APIAnimalsRepository: AnimalsRepository, @unchecked Sendable {
    private let baseURL: String
    private let session: URLSession
    
    init(baseURL: String = "https://paws-n-us-backend.vercel.app", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func createAnimal(_ request: CreateAnimalRequest) async throws -> CreatedAnimal {
        let url = URL(string: "\(baseURL)/api/animals")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if needed
        // urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Convert images to base64
        let imageData = request.imageData?.map { $0.base64EncodedString() } ?? []
        
        let requestBody: [String: Any] = [
            "name": request.name,
            "species": request.species.rawValue,
            "breed": request.breed as Any,
            "age": request.age,
            "gender": request.gender.rawValue,
            "size": request.size?.rawValue as Any,
            "bio": request.bio,
            "traits": request.traits,
            "energy_level": request.energyLevel?.rawValue as Any,
            "good_with_kids": request.goodWithKids as Any,
            "good_with_pets": request.goodWithPets as Any,
            "house_trained": request.houseTrained as Any,
            "location": request.location,
            "special_needs": request.specialNeeds as Any,
            "is_spayed_neutered": request.isSpayedNeutered as Any,
            "medical_status": request.medicalStatus.rawValue,
            "medical_notes": request.medicalNotes as Any,
            "vaccinations": request.vaccinations as Any,
            "adoption_fee": request.adoptionFee as Any,
            "rescue_date": request.rescueDate?.ISO8601Format() as Any,
            "rescue_location": request.rescueLocation as Any,
            "rescue_story": request.rescueStory as Any,
            "image_data": imageData,
            "help_needed": request.helpNeeded.map { $0.rawValue }
        ]
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnimalRepositoryError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw AnimalRepositoryError.unauthorized
        }
        
        if httpResponse.statusCode >= 400 {
            // Try to parse error message
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorData["error"] as? String {
                throw AnimalRepositoryError.serverError(errorMessage)
            }
            throw AnimalRepositoryError.httpError(httpResponse.statusCode)
        }
        
        // Parse success response
        guard let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let animalData = responseData["animal"] as? [String: Any] else {
            throw AnimalRepositoryError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let animalJson = try JSONSerialization.data(withJSONObject: animalData)
        let createdAnimal = try decoder.decode(CreatedAnimal.self, from: animalJson)
        
        return createdAnimal
    }
    
    func uploadImages(_ images: [UIImage], for animalId: String) async throws -> [String] {
        // This would be used if we need separate image upload endpoint
        // For now, images are uploaded as part of the create request
        return []
    }
    
    func getAnimals(rescuerId: String? = nil, species: String? = nil, limit: Int = 20, offset: Int = 0) async throws -> AnimalsResponse {
        var components = URLComponents(string: "\(baseURL)/api/animals")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        
        if let rescuerId = rescuerId {
            queryItems.append(URLQueryItem(name: "rescuer_id", value: rescuerId))
        }
        
        if let species = species {
            queryItems.append(URLQueryItem(name: "species", value: species))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw AnimalRepositoryError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnimalRepositoryError.invalidResponse
        }
        
        if httpResponse.statusCode >= 400 {
            throw AnimalRepositoryError.httpError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let animalsResponse = try decoder.decode(AnimalsResponse.self, from: data)
        
        return animalsResponse
    }
}

// MARK: - Stub Implementation
#if DEBUG
struct StubAnimalsRepository: AnimalsRepository {
    func createAnimal(_ request: CreateAnimalRequest) async throws -> CreatedAnimal {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        return CreatedAnimal(
            id: UUID().uuidString,
            name: request.name,
            species: request.species.displayName,
            imageUrls: ["https://example.com/image1.jpg", "https://example.com/image2.jpg"],
            helpNeeded: request.helpNeeded.map { $0.displayName },
            message: "동물이 성공적으로 등록되었습니다!"
        )
    }
    
    func uploadImages(_ images: [UIImage], for animalId: String) async throws -> [String] {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return images.enumerated().map { index, _ in
            "https://example.com/\(animalId)_\(index + 1).jpg"
        }
    }
    
    func getAnimals(rescuerId: String?, species: String?, limit: Int, offset: Int) async throws -> AnimalsResponse {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let mockAnimals = [
            AnimalListItem(
                id: "1",
                name: "바둑이",
                breed: "믹스견",
                age: 3,
                gender: "수컷",
                location: "서울시 강남구",
                imageUrls: ["https://example.com/dog1.jpg"],
                isAvailable: true,
                createdAt: "2025-01-28T00:00:00Z"
            ),
            AnimalListItem(
                id: "2",
                name: "나비",
                breed: "고양이",
                age: 2,
                gender: "암컷",
                location: "서울시 서초구",
                imageUrls: ["https://example.com/cat1.jpg"],
                isAvailable: true,
                createdAt: "2025-01-27T00:00:00Z"
            )
        ]
        
        return AnimalsResponse(animals: mockAnimals, total: mockAnimals.count)
    }
}
#endif

// MARK: - Errors
enum AnimalRepositoryError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case httpError(Int)
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .invalidResponse:
            return "서버 응답을 처리할 수 없습니다."
        case .unauthorized:
            return "인증이 필요합니다."
        case .serverError(let message):
            return "서버 오류: \(message)"
        case .httpError(let code):
            return "HTTP 오류: \(code)"
        case .encodingError:
            return "데이터 인코딩 오류입니다."
        }
    }
}