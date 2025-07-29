import Foundation
import Supabase

struct SupabaseAdopterRepository: AdopterRepository, @unchecked Sendable {
    let client: SupabaseClient // SupabaseClient is not Sendable, hence @unchecked
    
    func getAdopter(by id: String) async throws -> Adopter? {
        do {
            let adopterDTO: AdopterDTO = try await client.from("adopters")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            return adopterDTO.toAdopter()
        } catch {
            // If no record found, return nil
            return nil
        }
    }
    
    func updatePreferences(adopterID: String, preferences: AdopterPreferences) async throws {
        try await client.from("adopters")
            .update(["preferences": preferences])
            .eq("id", value: adopterID)
            .execute()
    }
    
    func updateProfile(adopterID: String, name: String, bio: String, location: String) async throws {
        try await client.from("adopters")
            .update([
                "name": name,
                "bio": bio,
                "location": location
            ])
            .eq("id", value: adopterID)
            .execute()
    }
}