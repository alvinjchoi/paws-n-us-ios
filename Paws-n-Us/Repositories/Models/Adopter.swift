//
//  Adopter.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation

struct Adopter: Codable, Equatable, Sendable {
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
    
    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         location: String,
         bio: String = "",
         profileImageURL: String? = nil,
         preferences: AdopterPreferences = AdopterPreferences(),
         likedDogIDs: [String] = [],
         dislikedDogIDs: [String] = [],
         matchedDogIDs: [String] = [],
         registrationDate: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.location = location
        self.bio = bio
        self.profileImageURL = profileImageURL
        self.preferences = preferences
        self.likedDogIDs = likedDogIDs
        self.dislikedDogIDs = dislikedDogIDs
        self.matchedDogIDs = matchedDogIDs
        self.registrationDate = registrationDate
    }
    
}

struct AdopterPreferences: Codable, Sendable {
    var preferredSizes: [DogSize]
    var preferredAgeRange: ClosedRange<Int>
    var preferredEnergyLevels: [EnergyLevel]
    var hasKids: Bool
    var hasOtherPets: Bool
    var maxDistance: Double
    
    init(preferredSizes: [DogSize] = DogSize.allCases,
         preferredAgeRange: ClosedRange<Int> = 0...20,
         preferredEnergyLevels: [EnergyLevel] = EnergyLevel.allCases,
         hasKids: Bool = false,
         hasOtherPets: Bool = false,
         maxDistance: Double = 50.0) {
        self.preferredSizes = preferredSizes
        self.preferredAgeRange = preferredAgeRange
        self.preferredEnergyLevels = preferredEnergyLevels
        self.hasKids = hasKids
        self.hasOtherPets = hasOtherPets
        self.maxDistance = maxDistance
    }
}

// MARK: - Equatable
extension Adopter {
    static func == (lhs: Adopter, rhs: Adopter) -> Bool {
        lhs.id == rhs.id
    }
}