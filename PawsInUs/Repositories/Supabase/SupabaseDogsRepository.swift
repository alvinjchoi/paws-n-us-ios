import Foundation
import Supabase

struct SupabaseDogsRepository: DogsRepository {
    let client: SupabaseClient
    
    func getDogs() async throws -> [Dog] {
        do {
            let dogDTOs: [DogDTO] = try await client.from("dogs")
                .select()
                .execute()
                .value
            
            print("Fetched \(dogDTOs.count) dogs")
            
            return dogDTOs.map { $0.toDog() }
        } catch {
            print("Error fetching dogs: \(error)")
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