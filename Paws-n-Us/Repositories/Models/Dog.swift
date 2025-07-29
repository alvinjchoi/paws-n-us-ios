//
//  Dog.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation

struct Dog: Codable, Equatable, Sendable, Identifiable {
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
    let personality: String?
    let healthStatus: String?
    let rescuerID: String?
    
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
         dateAdded: Date = Date(),
         personality: String? = nil,
         healthStatus: String? = nil,
         rescuerID: String? = nil) {
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
        self.personality = personality
        self.healthStatus = healthStatus
        self.rescuerID = rescuerID
    }
}

enum DogSize: String, Codable, CaseIterable, Sendable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extraLarge"
    
    var displayName: String {
        switch self {
        case .small: return "소형견"
        case .medium: return "중형견"
        case .large: return "대형견"
        case .extraLarge: return "초대형견"
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
    
    // Custom decoding to handle "veryHigh" from API
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value {
        case "low": self = .low
        case "medium": self = .medium
        case "high": self = .high
        case "veryHigh", "very_high": self = .veryHigh
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid energy level: \(value)")
        }
    }
    
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

// MARK: - Preview
extension Dog {
    static var preview: Dog {
        Dog(
            id: "preview-1",
            name: "맥스",
            breed: "골든 리트리버",
            age: 3,
            size: .large,
            gender: .male,
            imageURLs: [
                "https://images.unsplash.com/photo-1552053831-71594a27632d",
                "https://images.unsplash.com/photo-1633722715463-d30f4f325e24"
            ],
            bio: "활발하고 친근한 골든 리트리버 맥스입니다. 사람을 정말 좋아하고 다른 강아지들과도 잘 지내요!",
            shelterID: "shelter-1",
            shelterName: "행복한 동물 보호소",
            location: "서울시 강남구",
            traits: ["친근함", "활발함", "똑똑함"],
            isGoodWithKids: true,
            isGoodWithPets: true,
            energyLevel: .high,
            personality: "맥스는 매우 사교적이고 장난기 많은 강아지입니다. 공놀이를 특히 좋아하며, 새로운 사람을 만나는 것을 즐깁니다.",
            healthStatus: "건강 상태 양호. 모든 예방접종 완료. 중성화 수술 완료."
        )
    }
}