//
//  AnimalsRepository.swift
//  PawsInUs
//
//  Created by Assistant on 1/28/25.
//

import Foundation
import UIKit

// MARK: - Animal Creation Request
struct CreateAnimalRequest: Codable {
    let name: String
    let species: String
    let breed: String?
    let age: Int
    let gender: String
    let size: String?
    let bio: String
    let traits: [String]
    let energyLevel: String?
    let goodWithKids: Bool?
    let goodWithPets: Bool?
    let houseTrained: Bool?
    let location: String
    let specialNeeds: String?
    let isSpayedNeutered: Bool?
    let medicalStatus: String
    let medicalNotes: String?
    let vaccinations: String?
    let adoptionFee: Int?
    let rescueDate: Date?
    let rescueLocation: String?
    let rescueStory: String?
    let imageData: [Data]?
    let helpNeeded: [String]
}

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
}

struct AnimalsResponse: Codable {
    let animals: [Animal]
    let total: Int
    let limit: Int
    let offset: Int
}

struct Animal: Codable, Identifiable {
    let id: String
    let name: String
    let species: String
    let breed: String?
    let age: Int
    let gender: String
    let imageUrls: [String]
    let location: String
    let status: String
    let createdAt: Date
}

// MARK: - API Implementation
final class APIAnimalsRepository: AnimalsRepository {
    private let baseURL = "http://localhost:3000"
    
    func createAnimal(_ request: CreateAnimalRequest) async throws -> CreatedAnimal {
        guard let url = URL(string: "\(baseURL)/api/animals") else {
            throw AnimalsAPIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert request to dictionary for JSON encoding
        let requestDict: [String: Any] = [
            "name": request.name,
            "species": request.species,
            "breed": request.breed as Any,
            "age": request.age,
            "gender": request.gender,
            "size": request.size as Any,
            "bio": request.bio,
            "traits": request.traits,
            "energy_level": request.energyLevel as Any,
            "good_with_kids": request.goodWithKids as Any,
            "good_with_pets": request.goodWithPets as Any,
            "house_trained": request.houseTrained as Any,
            "location": request.location,
            "special_needs": request.specialNeeds as Any,
            "is_spayed_neutered": request.isSpayedNeutered as Any,
            "medical_status": request.medicalStatus,
            "medical_notes": request.medicalNotes as Any,
            "vaccinations": request.vaccinations as Any,
            "adoption_fee": request.adoptionFee as Any,
            "rescue_date": request.rescueDate?.timeIntervalSince1970 as Any,
            "rescue_location": request.rescueLocation as Any,
            "rescue_story": request.rescueStory as Any,
            "image_data": request.imageData?.map { $0.base64EncodedString() } as Any,
            "help_needed": request.helpNeeded
        ]
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestDict)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnimalsAPIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["error"] as? String {
                throw AnimalsAPIError.serverError(message)
            }
            throw AnimalsAPIError.httpError(httpResponse.statusCode)
        }
        
        let createdAnimal = try JSONDecoder().decode(CreatedAnimal.self, from: data)
        return createdAnimal
    }
    
    func uploadImages(_ images: [UIImage], for animalId: String) async throws -> [String] {
        // Implementation for image upload if needed separately
        return []
    }
    
    func getAnimals(rescuerId: String?, species: String?, limit: Int, offset: Int) async throws -> AnimalsResponse {
        var components = URLComponents(string: "\(baseURL)/api/animals")!
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        
        if let rescuerId = rescuerId {
            components.queryItems?.append(URLQueryItem(name: "rescuer_id", value: rescuerId))
        }
        
        if let species = species {
            components.queryItems?.append(URLQueryItem(name: "species", value: species))
        }
        
        guard let url = components.url else {
            throw AnimalsAPIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnimalsAPIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw AnimalsAPIError.httpError(httpResponse.statusCode)
        }
        
        let animalsResponse = try JSONDecoder().decode(AnimalsResponse.self, from: data)
        return animalsResponse
    }
}

// MARK: - Stub Implementation
final class StubAnimalsRepository: AnimalsRepository {
    func createAnimal(_ request: CreateAnimalRequest) async throws -> CreatedAnimal {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return CreatedAnimal(
            id: UUID().uuidString,
            name: request.name,
            species: request.species,
            imageUrls: ["https://example.com/image1.jpg", "https://example.com/image2.jpg"],
            helpNeeded: request.helpNeeded,
            message: "Animal created successfully"
        )
    }
    
    func uploadImages(_ images: [UIImage], for animalId: String) async throws -> [String] {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return images.enumerated().map { index, _ in
            "https://example.com/animal/\(animalId)/image\(index + 1).jpg"
        }
    }
    
    func getAnimals(rescuerId: String?, species: String?, limit: Int, offset: Int) async throws -> AnimalsResponse {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let sampleAnimals = [
            Animal(
                id: "1",
                name: "Buddy",
                species: "dog",
                breed: "Golden Retriever",
                age: 3,
                gender: "male",
                imageUrls: ["https://example.com/buddy1.jpg"],
                location: "Seoul",
                status: "available",
                createdAt: Date()
            ),
            Animal(
                id: "2",
                name: "Luna",
                species: "cat",
                breed: "Persian",
                age: 2,
                gender: "female",
                imageUrls: ["https://example.com/luna1.jpg"],
                location: "Busan",
                status: "available",
                createdAt: Date()
            )
        ]
        
        return AnimalsResponse(
            animals: Array(sampleAnimals.prefix(limit)),
            total: sampleAnimals.count,
            limit: limit,
            offset: offset
        )
    }
}

// MARK: - API Errors
enum AnimalsAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}