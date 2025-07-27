import Foundation
import Supabase

struct SupabaseMatchingRepository: MatchingRepository, @unchecked Sendable {
    let client: SupabaseClient // SupabaseClient is not Sendable, hence @unchecked
    
    func checkForMatch(adopterID: String, dogID: String) async throws -> Match? {
        do {
            _ = try await client.from("likes")
                .select()
                .eq("adopter_id", value: adopterID)
                .eq("dog_id", value: dogID)
                .single()
                .execute()
        } catch {
            // No like found, return nil
            return nil
        }
        
        let dogData: DogWithShelter = try await client.from("dogs")
            .select("*, shelter_id")
            .eq("id", value: dogID)
            .single()
            .execute()
            .value
        
        let matchDTO = MatchDTO(
            id: UUID().uuidString,
            dogID: dogID,
            adopterID: adopterID,
            shelterID: dogData.shelterID,
            matchDate: Date(),
            status: .matched,
            conversation: []
        )
        
        try await client.from("matches")
            .insert(matchDTO)
            .execute()
        
        // Get current adopter to update matched_dog_ids
        let adopterData: [String: [String]] = try await client.from("adopters")
            .select("matched_dog_ids")
            .eq("id", value: adopterID)
            .single()
            .execute()
            .value
        
        var matchedDogIDs = adopterData["matched_dog_ids"] ?? []
        matchedDogIDs.append(dogID)
        
        try await client.from("adopters")
            .update(["matched_dog_ids": matchedDogIDs])
            .eq("id", value: adopterID)
            .execute()
        
        return matchDTO.toMatch()
    }
}

private struct DogWithShelter: Decodable {
    let shelterID: String
    
    enum CodingKeys: String, CodingKey {
        case shelterID = "shelter_id"
    }
}