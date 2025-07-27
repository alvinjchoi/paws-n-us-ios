import Foundation
import Supabase

struct SupabaseDogsRepository: DogsRepository {
    let client: SupabaseClient
    
    func getDogs() async throws -> [Dog] {
        let response = try await client.from("dogs")
            .select()
            .execute()
        
        let dogs = try response.decode(to: [Dog].self)
        return dogs
    }
    
    func getDog(by id: String) async throws -> Dog {
        let response = try await client.from("dogs")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
        
        let dog = try response.decode(to: Dog.self)
        return dog
    }
}