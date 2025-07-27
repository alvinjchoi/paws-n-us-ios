import Foundation
import Supabase

struct SupabaseAuthRepository: AuthRepository {
    let client: SupabaseClient
    
    func signUp(email: String, password: String, name: String) async throws -> Adopter {
        let authResponse = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["name": AnyJSON(name)]
        )
        
        guard let userId = authResponse.user?.id.uuidString else {
            throw AuthError.signUpFailed
        }
        
        let adopter = Adopter(
            id: userId,
            name: name,
            email: email,
            location: "",
            bio: "",
            preferences: AdopterPreferences(
                preferredSizes: [],
                preferredAgeRange: 0...20,
                preferredEnergyLevels: [],
                hasKids: false,
                hasOtherPets: false,
                maxDistance: 50
            ),
            likedDogIDs: [],
            dislikedDogIDs: [],
            matchedDogIDs: []
        )
        
        try await client.from("adopters")
            .insert(adopter)
            .execute()
        
        return adopter
    }
    
    func signIn(email: String, password: String) async throws -> Adopter {
        try await client.auth.signIn(
            email: email,
            password: password
        )
        
        guard let userId = client.auth.currentUser?.id.uuidString else {
            throw AuthError.signInFailed
        }
        
        let response = try await client.from("adopters")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
        
        let adopter = try response.decode(to: Adopter.self)
        return adopter
    }
}

enum AuthError: Error {
    case signUpFailed
    case signInFailed
}