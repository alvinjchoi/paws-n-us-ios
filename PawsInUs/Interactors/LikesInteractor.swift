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
    func loadLikedDogs(dogs: Binding<Loadable<[Dog]>>)
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
    
    func loadLikedDogs(dogs: Binding<Loadable<[Dog]>>) {
        let cancelBag = CancelBag()
        dogs.wrappedValue = .isLoading(last: nil, cancelBag: cancelBag)
        
        let task = Task {
            let likedDogIDs = appState.value.userData.likedDogIDs
            let dogsRepository = self.dogsRepository
            var dogsList: [Dog] = []
            
            // Fetch each liked dog
            for dogID in likedDogIDs {
                do {
                    let dog = try await dogsRepository.getDog(by: dogID)
                    dogsList.append(dog)
                } catch {
                    // Skip dogs that can't be loaded
                    continue
                }
            }
            
            // Sort by most recently liked (reverse order since we append to the set)
            dogsList.reverse()
            
            // Capture the final list
            let finalDogs = dogsList
            
            await MainActor.run {
                dogs.wrappedValue = .loaded(finalDogs)
            }
        }
        task.store(in: cancelBag)
    }
    
    func unlikeDog(_ dog: Dog) {
        appState[\.userData.likedDogIDs].remove(dog.id)
        // Also remove from matched if it was matched
        appState[\.userData.matchedDogIDs].remove(dog.id)
    }
}