import Foundation
import Supabase

struct SupabaseDogsRepository: DogsRepository, @unchecked Sendable {
    let client: SupabaseClient // SupabaseClient is not Sendable, hence @unchecked
    
    func getDogs() async throws -> [Dog] {
        do {
            print("Attempting to fetch dogs from Supabase...")
            
            let dogDTOs: [DogDTO] = try await client.from("dogs")
                .select()
                .execute()
                .value
            
            print("Successfully fetched \(dogDTOs.count) dogs from Supabase")
            
            let dogs = dogDTOs.map { $0.toDog() }
            if !dogs.isEmpty {
                print("First dog: \(dogs[0].name) - \(dogs[0].breed)")
                print("First dog images: \(dogs[0].imageURLs)")
            }
            
            return dogs
        } catch {
            print("Error fetching dogs from Supabase: \(error)")
            print("Error details: \(error.localizedDescription)")
            if let postgrestError = error as? PostgrestError {
                print("Postgrest error: \(postgrestError)")
            }
            throw error
        }
    }
    
    func getDog(by id: String) async throws -> Dog {
        let dogDTO: DogDTO = try await client.from("dogs")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
        
        return dogDTO.toDog()
    }
}