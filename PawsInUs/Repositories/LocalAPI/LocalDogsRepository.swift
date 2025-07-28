import Foundation

struct LocalDogsRepository: DogsRepository {
    
    func getDogs() async throws -> [Dog] {
        let response = try await LocalAPIClient.shared.getAnimals()
        return response.animals.map { convertToDog($0) }
    }
    
    func getDog(by id: String) async throws -> Dog {
        // For now, fetch all and find by ID - you could add a specific endpoint later
        let response = try await LocalAPIClient.shared.getAnimals()
        guard let animal = response.animals.first(where: { $0.id == id }) else {
            throw NSError(domain: "LocalDogsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Dog not found"])
        }
        return convertToDog(animal)
    }
    
    func getDogsByRescuer(rescuerID: String) async throws -> [Dog] {
        // For now, return all animals since the local API doesn't track rescuer IDs properly
        // In production, you would want to properly associate animals with rescuers
        let response = try await LocalAPIClient.shared.getAnimals()
        return response.animals.map { convertToDog($0) }
    }
    
    // Convert from API model to domain model
    private func convertToDog(_ animal: AnimalListItem) -> Dog {
        // Convert size string to DogSize enum
        let dogSize: DogSize = {
            switch animal.size.lowercased() {
            case "small": return .small
            case "large": return .large
            case "extralarge", "extra_large": return .extraLarge
            default: return .medium
            }
        }()
        
        // Convert gender string to DogGender enum
        let dogGender: DogGender = {
            switch animal.gender.lowercased() {
            case "male": return .male
            case "female": return .female
            default: return .male // Default to male if unknown
            }
        }()
        
        return Dog(
            id: animal.id,
            name: animal.name,
            breed: animal.breed,
            age: animal.age,
            size: dogSize,
            gender: dogGender,
            imageURLs: animal.image_urls ?? [],
            bio: animal.bio ?? "",
            shelterID: "local-shelter", // Default shelter ID for local API
            shelterName: "Local Shelter", // Default shelter name
            location: animal.location,
            traits: [],  // Not provided in list response
            isGoodWithKids: false,  // Not provided in list response
            isGoodWithPets: false,  // Not provided in list response
            energyLevel: .medium,  // Default value
            dateAdded: Date(), // Use current date
            personality: nil,
            healthStatus: nil,
            rescuerID: nil  // Would need to be added to API response
        )
    }
}