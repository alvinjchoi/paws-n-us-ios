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
        dogs.wrappedValue = .isLoading(last: nil, cancelBag: CancelBag())
        
        let seenDogIDs = appState.value.userData.likedDogIDs.union(appState.value.userData.dislikedDogIDs)
        let repository = dogsRepository
        
        // Use completion-based approach as workaround for broken async/await
        if let supabaseRepo = repository as? SupabaseDogsRepository {
            supabaseRepo.getDogsWithCompletion { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let allDogs):
                        let unseenDogs = allDogs.filter { !seenDogIDs.contains($0.id) }
                        dogs.wrappedValue = .loaded(unseenDogs)
                    case .failure(let error):
                        dogs.wrappedValue = .failed(error)
                    }
                }
            }
        } else {
            // Fallback to async/await for other repositories
            Task {
                do {
                    let allDogs = try await repository.getDogs()
                    let unseenDogs = allDogs.filter { !seenDogIDs.contains($0.id) }
                    dogs.wrappedValue = .loaded(unseenDogs)
                } catch {
                    dogs.wrappedValue = .failed(error)
                }
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