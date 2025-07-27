//
//  SupabaseAuthRepository.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import Supabase

struct SupabaseAuthRepository: AuthRepository {
    let client: SupabaseClient
    
    func createAdopterProfile(userID: String, email: String, name: String) async throws -> Adopter {
        // Create adopter profile in the database
        let adopter = Adopter(
            id: userID,
            name: name,
            email: email,
            location: "Unknown"
        )
        
        // Insert into profiles table
        try await client.from("profiles")
            .insert([
                "id": userID,
                "name": name,
                "email": email,
                "location": adopter.location,
                "created_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
        
        return adopter
    }
    
    func getAdopterProfile(userID: String) async throws -> Adopter? {
        let response = try await client.from("profiles")
            .select()
            .eq("id", value: userID)
            .single()
            .execute()
        
        let profile = try JSONDecoder().decode(ProfileDTO.self, from: response.data)
        return profile.toAdopter()
    }
}

struct ProfileDTO: Codable {
    let id: String
    let name: String
    let email: String
    let bio: String?
    let location: String?
    let profileImageURL: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case bio
        case location
        case profileImageURL = "profile_image_url"
        case createdAt = "created_at"
    }
    
    func toAdopter() -> Adopter {
        return Adopter(
            id: id,
            name: name,
            email: email,
            location: location ?? "Unknown",
            bio: bio ?? "",
            profileImageURL: profileImageURL
        )
    }
}