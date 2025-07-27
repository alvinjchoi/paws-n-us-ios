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
        
        // Get liked dog IDs and repository before starting the task
        let likedDogIDs = appState.value.userData.likedDogIDs
        let repository = dogsRepository
        
        Task {
            var dogsList: [Dog] = []
            
            // Fetch each liked dog
            for dogID in likedDogIDs {
                do {
                    let dog = try await repository.getDog(by: dogID)
                    dogsList.append(dog)
                } catch {
                    // Skip dogs that can't be loaded
                    continue
                }
            }
            
            // Sort by most recently liked (reverse order since we append to the set)
            let finalDogsList = dogsList.reversed()
            dogs.wrappedValue = .loaded(Array(finalDogsList))
        }
    }
    
    func unlikeDog(_ dog: Dog) {
        appState[\.userData.likedDogIDs].remove(dog.id)
        // Also remove from matched if it was matched
        appState[\.userData.matchedDogIDs].remove(dog.id)
    }
}