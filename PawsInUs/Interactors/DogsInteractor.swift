//
//  DogsInteractor.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import SwiftUI
import Combine
import Supabase

protocol DogsInteractor {
    @MainActor func loadDogs(dogs: Binding<Loadable<[Dog]>>)
    @MainActor func likeDog(_ dog: Dog)
    func passDog(_ dog: Dog)
    func getDog(by id: String) async -> Dog?
}

extension DIContainer.Interactors {
    var dogsInteractor: DogsInteractor {
        RealDogsInteractor(
            appState: appState,
            dogsRepository: repositories.dogsRepository,
            matchingRepository: repositories.matchingRepository
        )
    }
}

struct RealDogsInteractor: DogsInteractor {
    let appState: Store<AppState>
    let dogsRepository: DogsRepository
    let matchingRepository: MatchingRepository
    
    @MainActor
    func loadDogs(dogs: Binding<Loadable<[Dog]>>) {
        print("🚀 loadDogs called")
        dogs.wrappedValue = .isLoading(last: nil, cancelBag: CancelBag())
        
        let seenDogIDs = appState.value.userData.likedDogIDs.union(appState.value.userData.dislikedDogIDs)
        
        // Use mock data for now
        let mockDogs = [
            Dog(id: "1", name: "Max", breed: "Golden Retriever", age: 3, size: .large, gender: .male, 
                imageURLs: ["https://images.unsplash.com/photo-1552053831-71594a27632d?w=500"], 
                bio: "Friendly and energetic", shelterID: "shelter1", shelterName: "Happy Paws", 
                location: "New York", traits: ["Friendly", "Playful"], isGoodWithKids: true, 
                isGoodWithPets: true, energyLevel: .high, dateAdded: Date()),
            Dog(id: "2", name: "Luna", breed: "Labrador", age: 2, size: .large, gender: .female,
                imageURLs: ["https://images.unsplash.com/photo-1537151625747-768eb6cf92b7?w=500"],
                bio: "Sweet and gentle", shelterID: "shelter1", shelterName: "Happy Paws",
                location: "New York", traits: ["Gentle", "Calm"], isGoodWithKids: true,
                isGoodWithPets: true, energyLevel: .medium, dateAdded: Date())
        ]
        
        let unseenDogs = mockDogs.filter { !seenDogIDs.contains($0.id) }
        dogs.wrappedValue = .loaded(unseenDogs)
    }
    
    @MainActor
    func likeDog(_ dog: Dog) {
        appState[\.userData.likedDogIDs].insert(dog.id)
        
        let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
        let repository = matchingRepository
        let dogID = dog.id
        
        Task {
            do {
                if try await repository.checkForMatch(adopterID: currentAdopterID, dogID: dogID) != nil {
                    appState[\.userData.matchedDogIDs].insert(dogID)
                    Self.showMatchNotification(dog: dog)
                }
            } catch {
                // Silently handle errors
            }
        }
    }
    
    func passDog(_ dog: Dog) {
        appState[\.userData.dislikedDogIDs].insert(dog.id)
    }
    
    func getDog(by id: String) async -> Dog? {
        do {
            return try await dogsRepository.getDog(by: id)
        } catch {
            return nil
        }
    }
    
    private static func showMatchNotification(dog: Dog) {
        // TODO: Implement actual notification
    }
}

protocol DogsRepository: Sendable {
    func getDogs() async throws -> [Dog]
    func getDog(by id: String) async throws -> Dog
}

protocol MatchingRepository: Sendable {
    func checkForMatch(adopterID: String, dogID: String) async throws -> Match?
}