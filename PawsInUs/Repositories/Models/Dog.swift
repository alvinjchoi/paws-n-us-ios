//
//  Dog.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import SwiftData

@Model
final class Dog: Codable {
    @Attribute(.unique) var id: String
    var name: String
    var breed: String
    var age: Int
    var size: DogSize
    var gender: DogGender
    var imageURLs: [String]
    var bio: String
    var shelterID: String
    var shelterName: String
    var location: String
    var traits: [String]
    var isGoodWithKids: Bool
    var isGoodWithPets: Bool
    var energyLevel: EnergyLevel
    var dateAdded: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         breed: String,
         age: Int,
         size: DogSize,
         gender: DogGender,
         imageURLs: [String],
         bio: String,
         shelterID: String,
         shelterName: String,
         location: String,
         traits: [String] = [],
         isGoodWithKids: Bool = false,
         isGoodWithPets: Bool = false,
         energyLevel: EnergyLevel = .medium,
         dateAdded: Date = Date()) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.size = size
        self.gender = gender
        self.imageURLs = imageURLs
        self.bio = bio
        self.shelterID = shelterID
        self.shelterName = shelterName
        self.location = location
        self.traits = traits
        self.isGoodWithKids = isGoodWithKids
        self.isGoodWithPets = isGoodWithPets
        self.energyLevel = energyLevel
        self.dateAdded = dateAdded
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, breed, age, size, gender, imageURLs, bio
        case shelterID, shelterName, location, traits
        case isGoodWithKids, isGoodWithPets, energyLevel, dateAdded
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        breed = try container.decode(String.self, forKey: .breed)
        age = try container.decode(Int.self, forKey: .age)
        size = try container.decode(DogSize.self, forKey: .size)
        gender = try container.decode(DogGender.self, forKey: .gender)
        imageURLs = try container.decode([String].self, forKey: .imageURLs)
        bio = try container.decode(String.self, forKey: .bio)
        shelterID = try container.decode(String.self, forKey: .shelterID)
        shelterName = try container.decode(String.self, forKey: .shelterName)
        location = try container.decode(String.self, forKey: .location)
        traits = try container.decode([String].self, forKey: .traits)
        isGoodWithKids = try container.decode(Bool.self, forKey: .isGoodWithKids)
        isGoodWithPets = try container.decode(Bool.self, forKey: .isGoodWithPets)
        energyLevel = try container.decode(EnergyLevel.self, forKey: .energyLevel)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(breed, forKey: .breed)
        try container.encode(age, forKey: .age)
        try container.encode(size, forKey: .size)
        try container.encode(gender, forKey: .gender)
        try container.encode(imageURLs, forKey: .imageURLs)
        try container.encode(bio, forKey: .bio)
        try container.encode(shelterID, forKey: .shelterID)
        try container.encode(shelterName, forKey: .shelterName)
        try container.encode(location, forKey: .location)
        try container.encode(traits, forKey: .traits)
        try container.encode(isGoodWithKids, forKey: .isGoodWithKids)
        try container.encode(isGoodWithPets, forKey: .isGoodWithPets)
        try container.encode(energyLevel, forKey: .energyLevel)
        try container.encode(dateAdded, forKey: .dateAdded)
    }
}

enum DogSize: String, Codable, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extraLarge"
    
    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .extraLarge: return "Extra Large"
        }
    }
}

enum DogGender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

enum EnergyLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case veryHigh = "veryHigh"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }
}