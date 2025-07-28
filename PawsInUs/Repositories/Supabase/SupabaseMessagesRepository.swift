import Foundation
import Supabase

// DTOs for Messages and Visits
struct MessageDBDTO: Codable, Sendable, Identifiable {
    let id: String
    let senderID: String
    let recipientID: String
    let animalID: String?
    let visitID: String?
    let subject: String?
    let content: String
    let messageType: String?
    let isRead: Bool?
    let readAt: String?
    let priority: String?
    let attachmentURLs: [String]?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderID = "sender_id"
        case recipientID = "recipient_id"
        case animalID = "animal_id"
        case visitID = "visit_id"
        case subject
        case content
        case messageType = "message_type"
        case isRead = "is_read"
        case readAt = "read_at"
        case priority
        case attachmentURLs = "attachment_urls"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct VisitDTO: Codable, Sendable, Identifiable {
    let id: String
    let rescuerID: String
    let adopterID: String
    let animalID: String
    let visitType: String?
    let scheduledDate: String
    let durationMinutes: Int?
    let location: String?
    let status: String?
    let rescuerNotes: String?
    let adopterNotes: String?
    let outcome: String?
    let requirements: [String]?
    let preparationNotes: String?
    let followUpRequired: Bool?
    let followUpDate: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case rescuerID = "rescuer_id"
        case adopterID = "adopter_id"
        case animalID = "animal_id"
        case visitType = "visit_type"
        case scheduledDate = "scheduled_date"
        case durationMinutes = "duration_minutes"
        case location
        case status
        case rescuerNotes = "rescuer_notes"
        case adopterNotes = "adopter_notes"
        case outcome
        case requirements
        case preparationNotes = "preparation_notes"
        case followUpRequired = "follow_up_required"
        case followUpDate = "follow_up_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct RescuerDTO: Codable, Sendable {
    let id: String
    let userID: String
    let organizationName: String?
    let registrationNumber: String?
    let verificationStatus: String?
    let specialties: [String]?
    let capacity: Int?
    let currentCount: Int?
    let location: String?
    let contactPhone: String?
    let contactEmail: String?
    let bio: String?
    let websiteURL: String?
    let socialMedia: [String: String]?
    let earningsTotal: Double?
    let rating: Double?
    let reviewCount: Int?
    let isActive: Bool?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case organizationName = "organization_name"
        case registrationNumber = "registration_number"
        case verificationStatus = "verification_status"
        case specialties
        case capacity
        case currentCount = "current_count"
        case location
        case contactPhone = "contact_phone"
        case contactEmail = "contact_email"
        case bio
        case websiteURL = "website_url"
        case socialMedia = "social_media"
        case earningsTotal = "earnings_total"
        case rating
        case reviewCount = "review_count"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

protocol MessagesRepository: Sendable {
    func createMessage(_ message: MessageDBDTO) async throws
    func getMessages(for recipientID: String) async throws -> [MessageDBDTO]
    func markMessageAsRead(_ messageID: String) async throws
}

protocol VisitsRepository: Sendable {
    func createVisit(_ visit: VisitDTO) async throws
    func getVisits(for rescuerID: String) async throws -> [VisitDTO]
    func getVisitsByDate(rescuerID: String, date: Date) async throws -> [VisitDTO]
    func updateVisitStatus(visitID: String, status: String) async throws
}

struct SupabaseMessagesRepository: MessagesRepository, @unchecked Sendable {
    let client: SupabaseClient
    
    func createMessage(_ message: MessageDBDTO) async throws {
        try await client.from("messages")
            .insert(message)
            .execute()
    }
    
    func getMessages(for recipientID: String) async throws -> [MessageDBDTO] {
        let messages: [MessageDBDTO] = try await client.from("messages")
            .select()
            .eq("recipient_id", value: recipientID)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return messages
    }
    
    func markMessageAsRead(_ messageID: String) async throws {
        struct MessageUpdate: Codable {
            let is_read: Bool
            let read_at: String
        }
        
        let update = MessageUpdate(
            is_read: true,
            read_at: ISO8601DateFormatter().string(from: Date())
        )
        
        try await client.from("messages")
            .update(update)
            .eq("id", value: messageID)
            .execute()
    }
}

struct SupabaseVisitsRepository: VisitsRepository, @unchecked Sendable {
    let client: SupabaseClient
    
    func createVisit(_ visit: VisitDTO) async throws {
        try await client.from("visits")
            .insert(visit)
            .execute()
    }
    
    func getVisits(for rescuerID: String) async throws -> [VisitDTO] {
        let visits: [VisitDTO] = try await client.from("visits")
            .select()
            .eq("rescuer_id", value: rescuerID)
            .order("scheduled_date", ascending: true)
            .execute()
            .value
        
        return visits
    }
    
    func getVisitsByDate(rescuerID: String, date: Date) async throws -> [VisitDTO] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let dateFormatter = ISO8601DateFormatter()
        let startDateString = dateFormatter.string(from: startOfDay)
        let endDateString = dateFormatter.string(from: endOfDay)
        
        let visits: [VisitDTO] = try await client.from("visits")
            .select()
            .eq("rescuer_id", value: rescuerID)
            .gte("scheduled_date", value: startDateString)
            .lt("scheduled_date", value: endDateString)
            .order("scheduled_date", ascending: true)
            .execute()
            .value
        
        return visits
    }
    
    func updateVisitStatus(visitID: String, status: String) async throws {
        try await client.from("visits")
            .update(["status": status])
            .eq("id", value: visitID)
            .execute()
    }
}

// Repository to get rescuer by user ID
protocol RescuerRepository: Sendable {
    func getRescuerByUserID(_ userID: String) async throws -> RescuerDTO?
}

struct SupabaseRescuerRepository: RescuerRepository, @unchecked Sendable {
    let client: SupabaseClient
    
    func getRescuerByUserID(_ userID: String) async throws -> RescuerDTO? {
        let rescuers: [RescuerDTO] = try await client.from("rescuers")
            .select()
            .eq("user_id", value: userID)
            .execute()
            .value
        
        return rescuers.first
    }
}