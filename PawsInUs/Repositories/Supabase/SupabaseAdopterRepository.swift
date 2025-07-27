import Foundation
import Supabase

struct SupabaseAdopterRepository: AdopterRepository {
    let client: SupabaseClient
    
    func getAdopter(by id: String) async throws -> Adopter? {
        let response = try await client.from("adopters")
            .select()
            .eq("id", value: id)
            .maybeSingle()
            .execute()
        
        return try response.decode(to: Adopter?.self)
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