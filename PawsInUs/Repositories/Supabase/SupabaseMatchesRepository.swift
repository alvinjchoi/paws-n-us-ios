import Foundation
import Supabase

struct SupabaseMatchesRepository: MatchesRepository {
    let client: SupabaseClient
    
    func getMatches(for adopterID: String) async throws -> [Match] {
        let response = try await client.from("matches")
            .select()
            .eq("adopter_id", value: adopterID)
            .execute()
        
        let matches = try response.decode(to: [Match].self)
        return matches
    }
    
    func sendMessage(matchID: String, message: Message) async throws {
        try await client.from("messages")
            .insert([
                "match_id": matchID,
                "sender_id": message.senderID,
                "content": message.content,
                "timestamp": message.timestamp
            ])
            .execute()
        
        try await client.from("matches")
            .update(["last_message_at": message.timestamp])
            .eq("id", value: matchID)
            .execute()
    }
    
    func updateMatchStatus(matchID: String, status: MatchStatus) async throws {
        try await client.from("matches")
            .update(["status": status.rawValue])
            .eq("id", value: matchID)
            .execute()
    }
}