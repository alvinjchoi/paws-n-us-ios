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
    @MainActor func loadProfile(adopter: Binding<Loadable<Adopter>>)
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
    
    @MainActor
    func loadProfile(adopter: Binding<Loadable<Adopter>>) {
        adopter.wrappedValue = .isLoading(last: nil, cancelBag: CancelBag())
        
        let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
        let repository = adopterRepository
        
        Task {
            do {
                let profile = try await repository.getAdopter(by: currentAdopterID)
                
                if let profile = profile {
                    adopter.wrappedValue = .loaded(profile)
                } else {
                    adopter.wrappedValue = .failed(AdopterError.notFound)
                }
            } catch {
                adopter.wrappedValue = .failed(error)
            }
        }
    }
    
    func updatePreferences(_ preferences: AdopterPreferences) {
        let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
        let repository = adopterRepository
        
        Task {
            do {
                try await repository.updatePreferences(adopterID: currentAdopterID, preferences: preferences)
            } catch {
                print("Error updating preferences: \(error)")
            }
        }
    }
    
    func updateProfile(name: String, bio: String, location: String) {
        let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
        let repository = adopterRepository
        
        Task {
            do {
                try await repository.updateProfile(
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

enum AdopterError: Error, LocalizedError {
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Profile not found. Please sign in or create an account."
        }
    }
}

protocol AdopterRepository: Sendable {
    func getAdopter(by id: String) async throws -> Adopter?
    func updatePreferences(adopterID: String, preferences: AdopterPreferences) async throws
    func updateProfile(adopterID: String, name: String, bio: String, location: String) async throws
}