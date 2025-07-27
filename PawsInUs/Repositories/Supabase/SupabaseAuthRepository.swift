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
        
        let userId = authResponse.user.id.uuidString
        
        let adopterDTO = AdopterDTO(
            id: userId,
            name: name,
            email: email,
            location: "",
            bio: "",
            profileImageURL: nil,
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
            matchedDogIDs: [],
            registrationDate: Date()
        )
        
        try await client.from("adopters")
            .insert(adopterDTO)
            .execute()
        
        return adopterDTO.toAdopter()
    }
    
    func signIn(email: String, password: String) async throws -> Adopter {
        try await client.auth.signIn(
            email: email,
            password: password
        )
        
        guard let userId = client.auth.currentUser?.id.uuidString else {
            throw AuthError.signInFailed
        }
        
        let adopterDTO: AdopterDTO = try await client.from("adopters")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        return adopterDTO.toAdopter()
    }
}

enum AuthError: Error {
    case signUpFailed
    case signInFailed
}