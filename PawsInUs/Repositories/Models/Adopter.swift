//
//  Adopter.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import SwiftData

@Model
final class Adopter: Codable {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var location: String
    var bio: String
    var profileImageURL: String?
    var preferences: AdopterPreferences
    var likedDogIDs: [String]
    var dislikedDogIDs: [String]
    var matchedDogIDs: [String]
    var registrationDate: Date
    
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
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, location, bio, profileImageURL
        case preferences, likedDogIDs, dislikedDogIDs, matchedDogIDs
        case registrationDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        location = try container.decode(String.self, forKey: .location)
        bio = try container.decode(String.self, forKey: .bio)
        profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        preferences = try container.decode(AdopterPreferences.self, forKey: .preferences)
        likedDogIDs = try container.decode([String].self, forKey: .likedDogIDs)
        dislikedDogIDs = try container.decode([String].self, forKey: .dislikedDogIDs)
        matchedDogIDs = try container.decode([String].self, forKey: .matchedDogIDs)
        registrationDate = try container.decode(Date.self, forKey: .registrationDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(location, forKey: .location)
        try container.encode(bio, forKey: .bio)
        try container.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
        try container.encode(preferences, forKey: .preferences)
        try container.encode(likedDogIDs, forKey: .likedDogIDs)
        try container.encode(dislikedDogIDs, forKey: .dislikedDogIDs)
        try container.encode(matchedDogIDs, forKey: .matchedDogIDs)
        try container.encode(registrationDate, forKey: .registrationDate)
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