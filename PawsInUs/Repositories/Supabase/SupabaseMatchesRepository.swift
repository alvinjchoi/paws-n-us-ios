import Foundation
import Supabase

struct SupabaseMatchesRepository: MatchesRepository {
    let client: SupabaseClient
    
    func getMatches(for adopterID: String) async throws -> [Match] {
        let matchDTOs: [MatchDTO] = try await client.from("matches")
            .select()
            .eq("adopter_id", value: adopterID)
            .execute()
            .value
        
        return matchDTOs.map { $0.toMatch() }
    }
    
    func sendMessage(matchID: String, message: Message) async throws {
        struct MessageInsert: Encodable {
            let match_id: String
            let sender_id: String
            let content: String
            let timestamp: String
        }
        
        let messageData = MessageInsert(
            match_id: matchID,
            sender_id: message.senderID,
            content: message.content,
            timestamp: ISO8601DateFormatter().string(from: message.timestamp)
        )
        
        try await client.from("messages")
            .insert(messageData)
            .execute()
        
        struct UpdateData: Encodable {
            let last_message_at: String
        }
        
        let updateData = UpdateData(last_message_at: ISO8601DateFormatter().string(from: message.timestamp))
        
        try await client.from("matches")
            .update(updateData)
            .eq("id", value: matchID)
            .execute()
    }
    
    func updateMatchStatus(matchID: String, status: MatchStatus) async throws {
        struct StatusUpdate: Encodable {
            let status: String
        }
        
        let updateData = StatusUpdate(status: status.rawValue)
        
        try await client.from("matches")
            .update(updateData)
            .eq("id", value: matchID)
            .execute()
    }
}