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
        print("DogsInteractor.loadDogs called")
        dogs.wrappedValue = .isLoading(last: nil, cancelBag: CancelBag())
        
        // Get the seen dog IDs before starting the task
        let seenDogIDs = appState.value.userData.likedDogIDs.union(appState.value.userData.dislikedDogIDs)
        print("Seen dog IDs: \(seenDogIDs)")
        
        // Now we can use proper async/await with Swift 6!
        Task {
            do {
                print("Loading dogs from repository...")
                let allDogs = try await dogsRepository.getDogs()
                print("Got \(allDogs.count) dogs from repository")
                
                let unseenDogs = allDogs.filter { !seenDogIDs.contains($0.id) }
                print("Filtered to \(unseenDogs.count) unseen dogs")
                
                dogs.wrappedValue = .loaded(unseenDogs)
                print("Dogs loaded successfully")
            } catch {
                print("Failed to load dogs: \(error)")
                dogs.wrappedValue = .failed(error)
            }
        }
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
                    _ = await MainActor.run {
                        appState[\.userData.matchedDogIDs].insert(dogID)
                    }
                    Self.showMatchNotification(dog: dog)
                }
            } catch {
                print("Error checking for match: \(error)")
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
            print("Error fetching dog: \(error)")
            return nil
        }
    }
    
    private static func showMatchNotification(dog: Dog) {
        print("It's a match with \(dog.name)!")
    }
}

protocol DogsRepository: Sendable {
    func getDogs() async throws -> [Dog]
    func getDog(by id: String) async throws -> Dog
}

protocol MatchingRepository: Sendable {
    func checkForMatch(adopterID: String, dogID: String) async throws -> Match?
}