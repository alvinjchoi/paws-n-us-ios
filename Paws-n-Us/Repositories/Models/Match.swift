//
//  Match.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation

struct Match: Codable, Equatable, Sendable {
    let id: String
    let dogID: String
    let adopterID: String
    let shelterID: String
    let matchDate: Date
    let status: MatchStatus
    let conversation: [Message]
    
    init(id: String = UUID().uuidString,
         dogID: String,
         adopterID: String,
         shelterID: String,
         matchDate: Date = Date(),
         status: MatchStatus = .matched,
         conversation: [Message] = []) {
        self.id = id
        self.dogID = dogID
        self.adopterID = adopterID
        self.shelterID = shelterID
        self.matchDate = matchDate
        self.status = status
        self.conversation = conversation
    }
    
}

enum MatchStatus: String, Codable, Sendable {
    case matched = "matched"
    case chatting = "chatting"
    case meetingScheduled = "meetingScheduled"
    case adopted = "adopted"
    case cancelled = "cancelled"
}

struct Message: Codable, Sendable, Equatable {
    let id: String
    let senderID: String
    let content: String
    let timestamp: Date
    
    init(id: String = UUID().uuidString,
         senderID: String,
         content: String,
         timestamp: Date = Date()) {
        self.id = id
        self.senderID = senderID
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - Equatable
extension Match {
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id
    }
}