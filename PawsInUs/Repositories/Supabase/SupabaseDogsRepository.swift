import Foundation
import Supabase

struct SupabaseDogsRepository: DogsRepository, @unchecked Sendable {
    let client: SupabaseClient // SupabaseClient is not Sendable, hence @unchecked
    
    // Add completion-based method for workaround
    func getDogsWithCompletion(completion: @escaping (Result<[Dog], Error>) -> Void) {
        print("🔍 getDogsWithCompletion called")
        guard let url = URL(string: "https://jxhtbzipglekixpogclo.supabase.co/rest/v1/dogs") else {
            print("❌ Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        
        print("📡 Making request to: \(url)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📨 Response status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            print("📦 Received \(data.count) bytes")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📋 Response: \(jsonString.prefix(500))...")
            }
            
            do {
                let dogDTOs = try JSONDecoder().decode([DogDTO].self, from: data)
                print("✅ Decoded \(dogDTOs.count) dogs")
                let dogs = dogDTOs.map { $0.toDog() }
                print("🐶 Mapped to Dog models, calling completion")
                completion(.success(dogs))
                print("✔️ Completion called")
            } catch {
                print("❌ Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Missing key: \(key.stringValue) - \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: \(type) - \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: \(type) - \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
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
}