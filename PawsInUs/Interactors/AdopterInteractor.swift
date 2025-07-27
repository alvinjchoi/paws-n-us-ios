//
//  AdopterInteractor.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import SwiftUI
import Combine

protocol AdopterInteractor {
    func loadProfile(adopter: Binding<Loadable<Adopter>>)
    func updatePreferences(_ preferences: AdopterPreferences)
    func updateProfile(name: String, bio: String, location: String)
}

extension DIContainer.Interactors {
    var adopterInteractor: AdopterInteractor {
        RealAdopterInteractor(
            appState: appState,
            adopterRepository: repositories.adopterRepository
        )
    }
}

struct RealAdopterInteractor: AdopterInteractor {
    let appState: Store<AppState>
    let adopterRepository: AdopterRepository
    
    func loadProfile(adopter: Binding<Loadable<Adopter>>) {
        let cancelBag = CancelBag()
        adopter.wrappedValue = .isLoading(last: nil, cancelBag: cancelBag)
        
        let task = Task {
            do {
                let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
                let profile = try await adopterRepository.getAdopter(by: currentAdopterID)
                if let profile = profile {
                    await MainActor.run {
                        adopter.wrappedValue = .loaded(profile)
                    }
                } else {
                    await MainActor.run {
                        adopter.wrappedValue = .failed(AdopterError.notFound)
                    }
                }
            } catch {
                await MainActor.run {
                    adopter.wrappedValue = .failed(error)
                }
            }
        }
        task.store(in: cancelBag)
    }
    
    func updatePreferences(_ preferences: AdopterPreferences) {
        Task {
            do {
                let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
                try await adopterRepository.updatePreferences(adopterID: currentAdopterID, preferences: preferences)
            } catch {
                print("Error updating preferences: \(error)")
            }
        }
    }
    
    func updateProfile(name: String, bio: String, location: String) {
        Task {
            do {
                let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
                try await adopterRepository.updateProfile(
                    adopterID: currentAdopterID,
                    name: name,
                    bio: bio,
                    location: location
                )
            } catch {
                print("Error updating profile: \(error)")
            }
        }
    }
}

enum AdopterError: Error {
    case notFound
}

protocol AdopterRepository {
    func getAdopter(by id: String) async throws -> Adopter?
    func updatePreferences(adopterID: String, preferences: AdopterPreferences) async throws
    func updateProfile(adopterID: String, name: String, bio: String, location: String) async throws
}