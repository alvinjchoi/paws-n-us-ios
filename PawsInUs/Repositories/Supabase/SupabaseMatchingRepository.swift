import Foundation
import Supabase

struct SupabaseMatchingRepository: MatchingRepository {
    let client: SupabaseClient
    
    func checkForMatch(adopterID: String, dogID: String) async throws -> Match? {
        let likesResponse = try await client.from("likes")
            .select()
            .eq("adopter_id", value: adopterID)
            .eq("dog_id", value: dogID)
            .maybeSingle()
            .execute()
        
        guard likesResponse.data != nil else {
            return nil
        }
        
        let dogResponse = try await client.from("dogs")
            .select("*, shelter_id")
            .eq("id", value: dogID)
            .single()
            .execute()
        
        let dogData = try dogResponse.decode(to: DogWithShelter.self)
        
        let match = Match(
            id: UUID().uuidString,
            dogID: dogID,
            adopterID: adopterID,
            shelterID: dogData.shelterID,
            matchDate: Date(),
            status: .matched,
            conversation: []
        )
        
        try await client.from("matches")
            .insert(match)
            .execute()
        
        try await client.from("adopters")
            .update(["matched_dog_ids": client.rpc.fn("array_append", params: ["matched_dog_ids", dogID])])
            .eq("id", value: adopterID)
            .execute()
        
        return match
    }
}

private struct DogWithShelter: Decodable {
    let shelterID: String
    
    enum CodingKeys: String, CodingKey {
        case shelterID = "shelter_id"
    }
}