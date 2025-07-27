//
//  DogsInteractor.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import SwiftUI
import Combine

protocol DogsInteractor {
    func loadDogs(dogs: Binding<Loadable<[Dog]>>)
    func likeDog(_ dog: Dog)
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
    
    func loadDogs(dogs: Binding<Loadable<[Dog]>>) {
        print("DogsInteractor.loadDogs called")
        let cancelBag = CancelBag()
        dogs.wrappedValue = .isLoading(last: nil, cancelBag: cancelBag)
        
        // Get the seen dog IDs before starting the task
        let seenDogIDs = appState.value.userData.likedDogIDs.union(appState.value.userData.dislikedDogIDs)
        print("Seen dog IDs: \(seenDogIDs)")
        
        let task = Task {
            do {
                print("About to call dogsRepository.getDogs()...")
                let allDogs = try await dogsRepository.getDogs()
                print("Got \(allDogs.count) dogs from repository")
                
                let unseenDogs = allDogs.filter { !seenDogIDs.contains($0.id) }
                print("Filtered to \(unseenDogs.count) unseen dogs")
                
                await MainActor.run {
                    dogs.wrappedValue = .loaded(unseenDogs)
                }
            } catch {
                print("Failed to load dogs: \(error)")
                await MainActor.run {
                    dogs.wrappedValue = .failed(error)
                }
            }
        }
        task.store(in: cancelBag)
    }
    
    func likeDog(_ dog: Dog) {
        appState[\.userData.likedDogIDs].insert(dog.id)
        
        Task {
            do {
                let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
                if try await matchingRepository.checkForMatch(adopterID: currentAdopterID, dogID: dog.id) != nil {
                    appState[\.userData.matchedDogIDs].insert(dog.id)
                    showMatchNotification(dog: dog)
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
    
    private func showMatchNotification(dog: Dog) {
        print("It's a match with \(dog.name)!")
    }
}

protocol DogsRepository {
    func getDogs() async throws -> [Dog]
    func getDog(by id: String) async throws -> Dog
}

protocol MatchingRepository {
    func checkForMatch(adopterID: String, dogID: String) async throws -> Match?
}