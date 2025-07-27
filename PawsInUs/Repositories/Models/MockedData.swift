//
//  MockedData.swift
//  Pawsinus
//
//  Created by Alexey Naumov on 27.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation

#if DEBUG

struct MockedData {
    static let dogs: [Dog] = [
        Dog(
            id: "1",
            name: "Max",
            breed: "Golden Retriever",
            age: 3,
            size: .large,
            gender: .male,
            imageURLs: [
                "https://images.unsplash.com/photo-1633722715463-d30f4f325e24",
                "https://images.unsplash.com/photo-1625316708582-7c38734be31d"
            ],
            bio: "Max is a friendly and energetic Golden Retriever who loves to play fetch and swim!",
            shelterID: "shelter1",
            shelterName: "Happy Paws Shelter",
            location: "San Francisco, CA",
            traits: ["Friendly", "Energetic", "Loves Water", "Good with Kids"],
            isGoodWithKids: true,
            isGoodWithPets: true,
            energyLevel: .high
        ),
        Dog(
            id: "2",
            name: "Luna",
            breed: "Siberian Husky",
            age: 2,
            size: .medium,
            gender: .female,
            imageURLs: [
                "https://images.unsplash.com/photo-1605568427561-40dd23c2acea",
                "https://images.unsplash.com/photo-1617895153857-82fe79adfcd4"
            ],
            bio: "Luna is a beautiful Husky with striking blue eyes. She's very intelligent and needs an active family.",
            shelterID: "shelter2",
            shelterName: "Second Chance Animal Rescue",
            location: "Los Angeles, CA",
            traits: ["Intelligent", "Active", "Vocal", "Escape Artist"],
            isGoodWithKids: true,
            isGoodWithPets: false,
            energyLevel: .veryHigh
        ),
        Dog(
            id: "3",
            name: "Charlie",
            breed: "French Bulldog",
            age: 4,
            size: .small,
            gender: .male,
            imageURLs: [
                "https://images.unsplash.com/photo-1583337130417-3346a1be7dee",
                "https://images.unsplash.com/photo-1599643477877-530eb83abc8e"
            ],
            bio: "Charlie is a charming Frenchie who loves cuddles and short walks. Perfect for apartment living!",
            shelterID: "shelter1",
            shelterName: "Happy Paws Shelter",
            location: "San Francisco, CA",
            traits: ["Calm", "Affectionate", "Snores", "Couch Potato"],
            isGoodWithKids: true,
            isGoodWithPets: true,
            energyLevel: .low
        )
    ]
    
    static let adopter = Adopter(
        id: "user1",
        name: "John Doe",
        email: "john@example.com",
        location: "San Francisco, CA",
        bio: "Dog lover looking for a furry companion to join my active lifestyle!",
        profileImageURL: "https://example.com/profile.jpg",
        preferences: AdopterPreferences(
            preferredSizes: [.medium, .large],
            preferredAgeRange: 1...5,
            preferredEnergyLevels: [.medium, .high],
            hasKids: false,
            hasOtherPets: true,
            maxDistance: 25.0
        ),
        likedDogIDs: ["1"],
        dislikedDogIDs: [],
        matchedDogIDs: ["1"]
    )
    
    static let matches: [Match] = [
        Match(
            id: "match1",
            dogID: "1",
            adopterID: "user1",
            shelterID: "shelter1",
            status: .matched,
            conversation: [
                Message(
                    senderID: "shelter1",
                    content: "Hi! We saw you matched with Max. Would you like to schedule a meet and greet?"
                ),
                Message(
                    senderID: "user1",
                    content: "Yes! I'd love to meet Max. When would be a good time?"
                )
            ]
        )
    ]
}

#endif
