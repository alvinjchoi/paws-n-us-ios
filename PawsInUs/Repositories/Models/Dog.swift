//
//  Dog.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation

struct Dog: Codable, Equatable, Sendable {
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
    let dateAdded: Date
    
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
}

enum DogSize: String, Codable, CaseIterable, Sendable {
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

enum DogGender: String, Codable, CaseIterable, Sendable {
    case male = "male"
    case female = "female"
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

enum EnergyLevel: String, Codable, CaseIterable, Sendable {
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

// MARK: - Equatable
extension Dog {
    static func == (lhs: Dog, rhs: Dog) -> Bool {
        lhs.id == rhs.id
    }
}