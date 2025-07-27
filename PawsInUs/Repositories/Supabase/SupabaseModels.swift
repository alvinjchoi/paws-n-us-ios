import Foundation

// Data transfer objects for Supabase operations
// These are separate from SwiftData models to avoid Sendable issues

struct AdopterDTO: Codable, Sendable {
    let id: String
    let name: String
    let email: String
    let location: String
    let bio: String
    let profileImageURL: String?
    let preferences: AdopterPreferences
    let likedDogIDs: [String]
    let dislikedDogIDs: [String]
    let matchedDogIDs: [String]
    let registrationDate: Date
    
    // Convert to SwiftData Adopter model
    func toAdopter() -> Adopter {
        return Adopter(
            id: id,
            name: name,
            email: email,
            location: location,
            bio: bio,
            profileImageURL: profileImageURL,
            preferences: preferences,
            likedDogIDs: likedDogIDs,
            dislikedDogIDs: dislikedDogIDs,
            matchedDogIDs: matchedDogIDs,
            registrationDate: registrationDate
        )
    }
    
    // Create from SwiftData Adopter model
    static func from(_ adopter: Adopter) -> AdopterDTO {
        return AdopterDTO(
            id: adopter.id,
            name: adopter.name,
            email: adopter.email,
            location: adopter.location,
            bio: adopter.bio,
            profileImageURL: adopter.profileImageURL,
            preferences: adopter.preferences,
            likedDogIDs: adopter.likedDogIDs,
            dislikedDogIDs: adopter.dislikedDogIDs,
            matchedDogIDs: adopter.matchedDogIDs,
            registrationDate: adopter.registrationDate
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case location
        case bio
        case profileImageURL = "profile_image_url"
        case preferences
        case likedDogIDs = "liked_dog_ids"
        case dislikedDogIDs = "disliked_dog_ids"
        case matchedDogIDs = "matched_dog_ids"
        case registrationDate = "registration_date"
    }
}

struct DogDTO: Codable, Sendable {
    let id: String
    let name: String
    let breed: String
    let age: Int
    let size: DogSize
    let gender: DogGender
    let imageURLs: [String]
    let bio: String
    let shelterID: String
    let shelterName: String
    let location: String
    let traits: [String]
    let isGoodWithKids: Bool
    let isGoodWithPets: Bool
    let energyLevel: EnergyLevel
    let dateAdded: String // Changed to String to match API response
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case breed
        case age
        case size
        case gender
        case imageURLs = "image_urls"
        case bio
        case shelterID = "shelter_id"
        case shelterName = "shelter_name"
        case location
        case traits
        case isGoodWithKids = "good_with_kids"
        case isGoodWithPets = "good_with_pets"
        case energyLevel = "energy_level"
        case dateAdded = "date_added"
    }
    
    func toDog() -> Dog {
        // Convert string date to Date
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: dateAdded) ?? Date()
        
        return Dog(
            id: id,
            name: name,
            breed: breed,
            age: age,
            size: size,
            gender: gender,
            imageURLs: imageURLs,
            bio: bio,
            shelterID: shelterID,
            shelterName: shelterName,
            location: location,
            traits: traits,
            isGoodWithKids: isGoodWithKids,
            isGoodWithPets: isGoodWithPets,
            energyLevel: energyLevel,
            dateAdded: date
        )
    }
}

struct MatchDTO: Codable, Sendable {
    let id: String
    let dogID: String
    let adopterID: String
    let shelterID: String
    let matchDate: Date
    let status: MatchStatus
    let conversation: [MessageDTO]
    
    enum CodingKeys: String, CodingKey {
        case id
        case dogID = "dog_id"
        case adopterID = "adopter_id"
        case shelterID = "shelter_id"
        case matchDate = "match_date"
        case status
        case conversation
    }
    
    func toMatch() -> Match {
        return Match(
            id: id,
            dogID: dogID,
            adopterID: adopterID,
            shelterID: shelterID,
            matchDate: matchDate,
            status: status,
            conversation: conversation.map { $0.toMessage() }
        )
    }
}

struct MessageDTO: Codable, Sendable {
    let id: String
    let senderID: String
    let content: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderID = "sender_id"
        case content
        case timestamp
    }
    
    func toMessage() -> Message {
        return Message(
            id: id,
            senderID: senderID,
            content: content,
            timestamp: timestamp
        )
    }
}