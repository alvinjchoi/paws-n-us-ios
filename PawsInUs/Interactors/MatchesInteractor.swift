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
        let cancelBag = CancelBag()
        matches.wrappedValue = .isLoading(last: nil, cancelBag: cancelBag)
        
        let task = Task {
            do {
                let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
                let allMatches = try await matchesRepository.getMatches(for: currentAdopterID)
                
                await MainActor.run {
                    matches.wrappedValue = .loaded(allMatches)
                }
            } catch {
                await MainActor.run {
                    matches.wrappedValue = .failed(error)
                }
            }
        }
        task.store(in: cancelBag)
    }
    
    func sendMessage(matchID: String, message: String) {
        Task {
            do {
                let currentAdopterID = appState.value.userData.currentAdopterID ?? ""
                let newMessage = Message(senderID: currentAdopterID, content: message)
                try await matchesRepository.sendMessage(matchID: matchID, message: newMessage)
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
    
    func updateMatchStatus(matchID: String, status: MatchStatus) {
        Task {
            do {
                try await matchesRepository.updateMatchStatus(matchID: matchID, status: status)
            } catch {
                print("Error updating match status: \(error)")
            }
        }
    }
}

protocol MatchesRepository {
    func getMatches(for adopterID: String) async throws -> [Match]
    func sendMessage(matchID: String, message: Message) async throws
    func updateMatchStatus(matchID: String, status: MatchStatus) async throws
}