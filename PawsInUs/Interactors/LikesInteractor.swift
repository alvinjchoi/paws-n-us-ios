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
        print("🐕 LikesInteractor: Starting to load liked dogs")
        dogs.wrappedValue = .isLoading(last: nil, cancelBag: CancelBag())
        
        let likedDogIDs = Array(appState.value.userData.likedDogIDs)
        let repository = dogsRepository
        
        print("🐕 LikesInteractor: Found \(likedDogIDs.count) liked dog IDs: \(likedDogIDs)")
        
        guard !likedDogIDs.isEmpty else {
            print("🐕 LikesInteractor: No liked dogs found, returning empty array")
            dogs.wrappedValue = .loaded([])
            return
        }
        
        // Use the same completion-based approach as DogsInteractor
        if let supabaseRepo = repository as? SupabaseDogsRepository {
            print("🐕 LikesInteractor: Using Supabase repository to fetch all dogs")
            
            // Add timeout to prevent infinite loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if case .isLoading = dogs.wrappedValue {
                    print("🐕 LikesInteractor: Request timed out after 10 seconds")
                    dogs.wrappedValue = .failed(NSError(domain: "Request timeout", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request timed out"]))
                }
            }
            
            supabaseRepo.getDogsWithCompletion { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let allDogs):
                        print("🐕 LikesInteractor: Successfully fetched \(allDogs.count) dogs from Supabase")
                        // Filter to only liked dogs and maintain order
                        let sortedLikedDogs = likedDogIDs.compactMap { id in
                            allDogs.first { $0.id == id }
                        }
                        print("🐕 LikesInteractor: Found \(sortedLikedDogs.count) liked dogs after filtering")
                        for dog in sortedLikedDogs {
                            print("🐕 Liked dog: \(dog.name) - Images: \(dog.imageURLs)")
                        }
                        dogs.wrappedValue = .loaded(sortedLikedDogs)
                        print("🐕 LikesInteractor: Successfully completed request")
                    case .failure(let error):
                        print("🐕 LikesInteractor: Failed to fetch dogs: \(error)")
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