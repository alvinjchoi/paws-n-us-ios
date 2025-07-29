//
//  LikesInteractor.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import SwiftUI
import Combine

protocol LikesInteractor {
    @MainActor func loadLikedDogs(dogs: Binding<Loadable<[Dog]>>)
    func unlikeDog(_ dog: Dog)
}

extension DIContainer.Interactors {
    var likesInteractor: LikesInteractor {
        RealLikesInteractor(
            appState: appState,
            dogsRepository: repositories.dogsRepository
        )
    }
}

struct RealLikesInteractor: LikesInteractor {
    let appState: Store<AppState>
    let dogsRepository: DogsRepository
    
    @MainActor
    func loadLikedDogs(dogs: Binding<Loadable<[Dog]>>) {
        dogs.wrappedValue = .isLoading(last: nil, cancelBag: CancelBag())
        
        let likedDogIDs = Array(appState.value.userData.likedDogIDs)
        let repository = dogsRepository
        
        
        guard !likedDogIDs.isEmpty else {
            dogs.wrappedValue = .loaded([])
            return
        }
        
        // Use the same completion-based approach as DogsInteractor
        if let supabaseRepo = repository as? SupabaseDogsRepository {
            
            // Add timeout to prevent infinite loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if case .isLoading = dogs.wrappedValue {
                    dogs.wrappedValue = .failed(NSError(domain: "Request timeout", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request timed out"]))
                }
            }
            
            supabaseRepo.getDogsWithCompletion { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let allDogs):
                        // Filter to only liked dogs and maintain order
                        let sortedLikedDogs = likedDogIDs.compactMap { id in
                            allDogs.first { $0.id == id }
                        }
                        dogs.wrappedValue = .loaded(sortedLikedDogs)
                    case .failure(let error):
                        dogs.wrappedValue = .failed(error)
                    }
                }
            }
        } else {
            // Fallback to async/await for other repositories
            Task {
                var dogsList: [Dog] = []
                
                for dogID in likedDogIDs {
                    do {
                        let dog = try await repository.getDog(by: dogID)
                        dogsList.append(dog)
                    } catch {
                        continue
                    }
                }
                
                await MainActor.run {
                    dogs.wrappedValue = .loaded(Array(dogsList.reversed()))
                }
            }
        }
    }
    
    func unlikeDog(_ dog: Dog) {
        appState[\.userData.likedDogIDs].remove(dog.id)
        // Also remove from matched if it was matched
        appState[\.userData.matchedDogIDs].remove(dog.id)
    }
}