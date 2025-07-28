import Foundation
import Supabase

struct SupabaseDogsRepository: DogsRepository, @unchecked Sendable {
    let client: SupabaseClient // SupabaseClient is not Sendable, hence @unchecked
    
    // Add completion-based method for workaround
    func getDogsWithCompletion(completion: @escaping @Sendable (Result<[Dog], Error>) -> Void) {
        guard let url = URL(string: "https://jxhtbzipglekixpogclo.supabase.co/rest/v1/dogs") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            do {
                let dogDTOs = try JSONDecoder().decode([DogDTO].self, from: data)
                let dogs = dogDTOs.map { $0.toDog() }
                completion(.success(dogs))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
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
    
    func getDogsByRescuer(rescuerID: String) async throws -> [Dog] {
        let dogDTOs: [DogDTO] = try await client.from("dogs")
            .select()
            .eq("rescuer_id", value: rescuerID)
            .execute()
            .value
        
        return dogDTOs.map { $0.toDog() }
    }
}