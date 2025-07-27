//
//  Match.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation

final class Match: Codable, Equatable {
    var id: String
    var dogID: String
    var adopterID: String
    var shelterID: String
    var matchDate: Date
    var status: MatchStatus
    var conversation: [Message]
    
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
    
    enum CodingKeys: String, CodingKey {
        case id, dogID, adopterID, shelterID, matchDate, status, conversation
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        dogID = try container.decode(String.self, forKey: .dogID)
        adopterID = try container.decode(String.self, forKey: .adopterID)
        shelterID = try container.decode(String.self, forKey: .shelterID)
        matchDate = try container.decode(Date.self, forKey: .matchDate)
        status = try container.decode(MatchStatus.self, forKey: .status)
        conversation = try container.decode([Message].self, forKey: .conversation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(dogID, forKey: .dogID)
        try container.encode(adopterID, forKey: .adopterID)
        try container.encode(shelterID, forKey: .shelterID)
        try container.encode(matchDate, forKey: .matchDate)
        try container.encode(status, forKey: .status)
        try container.encode(conversation, forKey: .conversation)
    }
}

enum MatchStatus: String, Codable {
    case matched = "matched"
    case chatting = "chatting"
    case meetingScheduled = "meetingScheduled"
    case adopted = "adopted"
    case cancelled = "cancelled"
}

struct Message: Codable, Sendable, Equatable {
    var id: String
    var senderID: String
    var content: String
    var timestamp: Date
    
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