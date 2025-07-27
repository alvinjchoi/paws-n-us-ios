//
//  MatchesInteractor.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import SwiftUI
import Combine

protocol MatchesInteractor {
    func loadMatches(matches: Binding<Loadable<[Match]>>)
    func sendMessage(matchID: String, message: String)
    func updateMatchStatus(matchID: String, status: MatchStatus)
}

extension DIContainer.Interactors {
    var matchesInteractor: MatchesInteractor {
        RealMatchesInteractor(
            appState: appState,
            matchesRepository: repositories.matchesRepository
        )
    }
}

struct RealMatchesInteractor: MatchesInteractor {
    let appState: Store<AppState>
    let matchesRepository: MatchesRepository
    
    func loadMatches(matches: Binding<Loadable<[Match]>>) {
        matches.wrappedValue = .isLoading(last: nil, cancelBag: CancelBag())
        
        // Get adopter ID and repository reference before starting the task
        let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
        let repository = matchesRepository
        
        Task { @MainActor in
            do {
                let allMatches = try await repository.getMatches(for: currentAdopterID)
                matches.wrappedValue = .loaded(allMatches)
            } catch {
                matches.wrappedValue = .failed(error)
            }
        }
    }
    
    func sendMessage(matchID: String, message: String) {
        let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
        let repository = matchesRepository
        
        Task {
            do {
                let newMessage = Message(senderID: currentAdopterID, content: message)
                try await repository.sendMessage(matchID: matchID, message: newMessage)
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
    
    func updateMatchStatus(matchID: String, status: MatchStatus) {
        let repository = matchesRepository
        
        Task {
            do {
                try await repository.updateMatchStatus(matchID: matchID, status: status)
            } catch {
                print("Error updating match status: \(error)")
            }
        }
    }
}

protocol MatchesRepository: Sendable {
    func getMatches(for adopterID: String) async throws -> [Match]
    func sendMessage(matchID: String, message: Message) async throws
    func updateMatchStatus(matchID: String, status: MatchStatus) async throws
}