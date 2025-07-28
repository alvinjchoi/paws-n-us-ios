//
//  LocalAPIClient.swift
//  PawsInUs
//
//  API client for local backend at http://127.0.0.1:5500
//

import Foundation
import UIKit

enum LocalAPIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}

struct LocalAPIClient {
    static let shared = LocalAPIClient()
    
    private let baseURL = "https://pawsnus.com"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Animal Creation
    func createAnimal(
        name: String,
        species: String,
        breed: String?,
        age: Int,
        gender: String,
        size: String,
        bio: String,
        traits: [String],
        energyLevel: String,
        goodWithKids: Bool,
        goodWithPets: Bool,
        houseTrained: Bool,
        location: String,
        specialNeeds: String?,
        isSpayedNeutered: Bool,
        medicalStatus: String,
        medicalNotes: String?,
        vaccinations: String?,
        weight: Double?,
        adoptionFee: Double?,
        rescueDate: Date?,
        rescueLocation: String?,
        rescueStory: String?,
        images: [UIImage],
        helpNeeded: [String],
        rescuerId: String?,
        authToken: String?
    ) async throws -> AnimalCreationResponse {
        
        guard let url = URL(string: "\(baseURL)/api/animals") else {
            throw LocalAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let authToken = authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Convert images to base64
        let imageData = images.compactMap { image -> String? in
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            return data.base64EncodedString()
        }
        
        let requestBody = AnimalCreationRequest(
            name: name,
            species: species,
            breed: breed,
            age: age,
            gender: gender,
            size: size,
            bio: bio,
            traits: traits,
            energy_level: energyLevel,
            good_with_kids: goodWithKids,
            good_with_pets: goodWithPets,
            house_trained: houseTrained,
            location: location,
            special_needs: specialNeeds,
            is_spayed_neutered: isSpayedNeutered,
            medical_status: medicalStatus,
            medical_notes: medicalNotes,
            vaccinations: vaccinations,
            weight: weight,
            adoption_fee: adoptionFee,
            rescue_date: rescueDate?.ISO8601Format(),
            rescue_location: rescueLocation,
            rescue_story: rescueStory,
            image_data: imageData,
            help_needed: helpNeeded,
            rescuer_id: rescuerId
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LocalAPIError.serverError("Invalid response")
        }
        
        
        if httpResponse.statusCode == 401 {
            throw LocalAPIError.unauthorized
        }
        
        if httpResponse.statusCode != 201 {
            if let responseString = String(data: data, encoding: .utf8) {
            }
            if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw LocalAPIError.serverError(errorData.error)
            }
            throw LocalAPIError.serverError("Status code: \(httpResponse.statusCode)")
        }
        
        let creationResponse = try JSONDecoder().decode(AnimalCreationResponse.self, from: data)
        return creationResponse
    }
    
    // MARK: - Get Animals
    func getAnimals(
        rescuerId: String? = nil,
        species: String? = nil,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> AnimalsListResponse {
        
        var components = URLComponents(string: "\(baseURL)/api/animals")
        components?.queryItems = []
        
        if let rescuerId = rescuerId {
            components?.queryItems?.append(URLQueryItem(name: "rescuer_id", value: rescuerId))
        }
        if let species = species {
            components?.queryItems?.append(URLQueryItem(name: "species", value: species))
        }
        components?.queryItems?.append(URLQueryItem(name: "limit", value: String(limit)))
        components?.queryItems?.append(URLQueryItem(name: "offset", value: String(offset)))
        
        guard let url = components?.url else {
            throw LocalAPIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LocalAPIError.serverError("Failed to fetch animals")
        }
        
        let listResponse = try JSONDecoder().decode(AnimalsListResponse.self, from: data)
        return listResponse
    }
}

// MARK: - Request/Response Models
struct AnimalCreationRequest: Encodable {
    let name: String
    let species: String
    let breed: String?
    let age: Int
    let gender: String
    let size: String
    let bio: String
    let traits: [String]
    let energy_level: String
    let good_with_kids: Bool
    let good_with_pets: Bool
    let house_trained: Bool
    let location: String
    let special_needs: String?
    let is_spayed_neutered: Bool
    let medical_status: String
    let medical_notes: String?
    let vaccinations: String?
    let weight: Double?
    let adoption_fee: Double?
    let rescue_date: String?
    let rescue_location: String?
    let rescue_story: String?
    let image_data: [String]
    let help_needed: [String]
    let rescuer_id: String?
}

struct AnimalCreationResponse: Decodable {
    let success: Bool
    let animal: LocalCreatedAnimal
}

struct LocalCreatedAnimal: Decodable {
    let id: String
    let name: String
    let species: String
    let imageUrls: [String]
    let helpNeeded: [String]
    let message: String
}

struct AnimalsListResponse: Decodable {
    let animals: [AnimalListItem]
    let total: Int
}

struct AnimalListItem: Decodable {
    let id: String
    let name: String
    let breed: String
    let age: Int
    let gender: String
    let size: String
    let bio: String?
    let location: String
    let image_urls: [String]?
    let is_available: Bool
    let created_at: String
}

struct ErrorResponse: Decodable {
    let error: String
    let details: String?
}
