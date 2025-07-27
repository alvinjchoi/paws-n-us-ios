import Foundation
import Supabase

struct SupabaseDogsRepository: DogsRepository, @unchecked Sendable {
    let client: SupabaseClient // SupabaseClient is not Sendable, hence @unchecked
    
    func getDogs() async throws -> [Dog] {
        let dogDTOs: [DogDTO] = try await client.from("dogs")
            .select()
            .execute()
            .value
        
        return dogDTOs.map { $0.toDog() }
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