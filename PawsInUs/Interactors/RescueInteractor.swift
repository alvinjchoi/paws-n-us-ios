//
//  RescueInteractor.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import Foundation
import Combine
import Supabase
import SwiftUI

// MARK: - DIContainer Extension
extension DIContainer.Interactors {
    var rescueInteractor: RescueInteractor {
        RealRescueInteractor(supabaseClient: SupabaseConfig.client)
    }
}

protocol RescueInteractor: Sendable {
    func getCurrentRescuer() async throws -> Rescuer?
    func createRescuerProfile(_ profile: CreateRescuerProfile) async throws -> Rescuer
    func updateRescuerProfile(_ rescuer: Rescuer) async throws -> Rescuer
    
    func getRescueAnimals(for rescuerId: String) async throws -> [RescueAnimal]
    func addRescueAnimal(_ animal: CreateRescueAnimal) async throws -> RescueAnimal
    func updateRescueAnimal(_ animal: RescueAnimal) async throws -> RescueAnimal
    func deleteRescueAnimal(id: String) async throws
    
    func getVisits(for rescuerId: String, status: VisitStatus?) async throws -> [Visit]
    func createVisit(_ visit: CreateVisit) async throws -> Visit
    func updateVisit(_ visit: Visit) async throws -> Visit
    
    func getTransactions(for rescuerId: String, dateRange: DateInterval?) async throws -> [Transaction]
    func addTransaction(_ transaction: CreateTransaction) async throws -> Transaction
    
    func getMessages(for userId: String, animalId: String?) async throws -> [RescueMessage]
    func sendMessage(_ message: CreateMessage) async throws -> RescueMessage
    func markMessageAsRead(id: String) async throws
}

struct RealRescueInteractor: RescueInteractor {
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    // MARK: - Rescuer Profile Management
    
    func getCurrentRescuer() async throws -> Rescuer? {
        guard let user = supabaseClient.auth.currentUser else {
            return nil
        }
        
        let response = try await supabaseClient
            .from("rescuers")
            .select()
            .eq("user_id", value: user.id)
            .execute()
        
        let rescuers = try JSONDecoder().decode([Rescuer].self, from: response.data)
        return rescuers.first
    }
    
    func createRescuerProfile(_ profile: CreateRescuerProfile) async throws -> Rescuer {
        guard let user = supabaseClient.auth.currentUser else {
            throw RescueError.unauthorized
        }
        
        struct RescuerInsert: Encodable {
            let user_id: String
            let organization_name: String?
            let registration_number: String?
            let specialties: [String]
            let capacity: Int
            let location: String?
            let contact_phone: String?
            let contact_email: String?
            let bio: String?
            let website_url: String?
        }
        
        let newRescuer = RescuerInsert(
            user_id: user.id.uuidString,
            organization_name: profile.organizationName,
            registration_number: profile.registrationNumber,
            specialties: profile.specialties,
            capacity: profile.capacity,
            location: profile.location,
            contact_phone: profile.contactPhone,
            contact_email: profile.contactEmail,
            bio: profile.bio,
            website_url: profile.websiteUrl
        )
        
        let response = try await supabaseClient
            .from("rescuers")
            .insert(newRescuer)
            .select()
            .execute()
        
        let rescuers = try JSONDecoder().decode([Rescuer].self, from: response.data)
        guard let rescuer = rescuers.first else {
            throw RescueError.creationFailed
        }
        
        return rescuer
    }
    
    func updateRescuerProfile(_ rescuer: Rescuer) async throws -> Rescuer {
        struct RescuerUpdate: Encodable {
            let organization_name: String?
            let registration_number: String?
            let specialties: [String]
            let capacity: Int
            let location: String?
            let contact_phone: String?
            let contact_email: String?
            let bio: String?
            let website_url: String?
            let social_media: [String: String]
        }
        
        let updateData = RescuerUpdate(
            organization_name: rescuer.organizationName,
            registration_number: rescuer.registrationNumber,
            specialties: rescuer.specialties,
            capacity: rescuer.capacity,
            location: rescuer.location,
            contact_phone: rescuer.contactPhone,
            contact_email: rescuer.contactEmail,
            bio: rescuer.bio,
            website_url: rescuer.websiteUrl,
            social_media: rescuer.socialMedia
        )
        
        let response = try await supabaseClient
            .from("rescuers")
            .update(updateData)
            .eq("id", value: rescuer.id)
            .select()
            .execute()
        
        let rescuers = try JSONDecoder().decode([Rescuer].self, from: response.data)
        guard let updatedRescuer = rescuers.first else {
            throw RescueError.updateFailed
        }
        
        return updatedRescuer
    }
    
    // MARK: - Rescue Animals Management
    
    func getRescueAnimals(for rescuerId: String) async throws -> [RescueAnimal] {
        let response = try await supabaseClient
            .from("dogs")
            .select()
            .eq("rescuer_id", value: rescuerId)
            .order("created_at", ascending: false)
            .execute()
        
        let animals = try JSONDecoder().decode([RescueAnimal].self, from: response.data)
        return animals
    }
    
    func addRescueAnimal(_ animal: CreateRescueAnimal) async throws -> RescueAnimal {
        guard let rescuer = try await getCurrentRescuer() else {
            throw RescueError.unauthorized
        }
        
        struct AnimalInsert: Encodable {
            let rescuer_id: String
            let name: String
            let breed: String
            let age: Int
            let size: String
            let gender: String
            let bio: String?
            let location: String
            let traits: [String]
            let energy_level: String
            let good_with_kids: Bool
            let good_with_pets: Bool
            let house_trained: Bool
            let special_needs: String?
            let adoption_fee: Double?
            let available: Bool
            let image_urls: [String]
            let rescue_date: String?
            let rescue_location: String?
            let rescue_story: String?
            let medical_status: String
            let medical_notes: String?
            let is_spayed_neutered: Bool
            let weight: Double?
            let rescuer_notes: String?
            let is_featured: Bool
            let vaccinations: [String: String]?
            let foster_family_id: String?
            let document_urls: [String]
            let date_added: String
        }
        
        let newAnimal = AnimalInsert(
            rescuer_id: rescuer.id,
            name: animal.name,
            breed: animal.breed,
            age: animal.age,
            size: animal.size.rawValue,
            gender: animal.gender.rawValue,
            bio: animal.bio,
            location: animal.location,
            traits: animal.traits,
            energy_level: animal.energyLevel.rawValue,
            good_with_kids: animal.isGoodWithKids,
            good_with_pets: animal.isGoodWithPets,
            house_trained: animal.houseTrained,
            special_needs: animal.specialNeeds,
            adoption_fee: animal.adoptionFee,
            available: animal.available,
            image_urls: animal.imageUrls,
            rescue_date: animal.rescueDate?.ISO8601Format(),
            rescue_location: animal.rescueLocation,
            rescue_story: animal.rescueStory,
            medical_status: animal.medicalStatus.rawValue,
            medical_notes: animal.medicalNotes,
            is_spayed_neutered: animal.isSpayedNeutered,
            weight: animal.weight,
            rescuer_notes: animal.rescuerNotes,
            is_featured: animal.isFeatured,
            vaccinations: animal.vaccinations,
            foster_family_id: animal.fosterFamilyId,
            document_urls: animal.documentUrls,
            date_added: Date().ISO8601Format()
        )
        
        let response = try await supabaseClient
            .from("dogs")
            .insert(newAnimal)
            .select()
            .execute()
        
        let animals = try JSONDecoder().decode([RescueAnimal].self, from: response.data)
        guard let createdAnimal = animals.first else {
            throw RescueError.creationFailed
        }
        
        return createdAnimal
    }
    
    func updateRescueAnimal(_ animal: RescueAnimal) async throws -> RescueAnimal {
        struct AnimalUpdate: Encodable {
            let name: String
            let breed: String
            let age: Int
            let size: String
            let gender: String
            let bio: String?
            let location: String
            let traits: [String]
            let energy_level: String
            let good_with_kids: Bool
            let good_with_pets: Bool
            let house_trained: Bool
            let special_needs: String?
            let adoption_fee: Double?
            let available: Bool
            let image_urls: [String]
            let rescue_date: String?
            let rescue_location: String?
            let rescue_story: String?
            let medical_status: String
            let medical_notes: String?
            let is_spayed_neutered: Bool
            let weight: Double?
            let rescuer_notes: String?
            let is_featured: Bool
            let vaccinations: [String: String]?
            let foster_family_id: String?
            let document_urls: [String]
        }
        
        let updateData = AnimalUpdate(
            name: animal.name,
            breed: animal.breed,
            age: animal.age,
            size: animal.size.rawValue,
            gender: animal.gender.rawValue,
            bio: animal.bio,
            location: animal.location,
            traits: animal.traits,
            energy_level: animal.energyLevel.rawValue,
            good_with_kids: animal.isGoodWithKids,
            good_with_pets: animal.isGoodWithPets,
            house_trained: animal.houseTrained,
            special_needs: animal.specialNeeds,
            adoption_fee: animal.adoptionFee,
            available: animal.available,
            image_urls: animal.imageUrls,
            rescue_date: animal.rescueDate?.ISO8601Format(),
            rescue_location: animal.rescueLocation,
            rescue_story: animal.rescueStory,
            medical_status: animal.medicalStatus.rawValue,
            medical_notes: animal.medicalNotes,
            is_spayed_neutered: animal.isSpayedNeutered,
            weight: animal.weight,
            rescuer_notes: animal.rescuerNotes,
            is_featured: animal.isFeatured,
            vaccinations: animal.vaccinations,
            foster_family_id: animal.fosterFamilyId,
            document_urls: animal.documentUrls
        )
        
        let response = try await supabaseClient
            .from("dogs")
            .update(updateData)
            .eq("id", value: animal.id)
            .select()
            .execute()
        
        let animals = try JSONDecoder().decode([RescueAnimal].self, from: response.data)
        guard let updatedAnimal = animals.first else {
            throw RescueError.updateFailed
        }
        
        return updatedAnimal
    }
    
    func deleteRescueAnimal(id: String) async throws {
        try await supabaseClient
            .from("dogs")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - Visits Management
    
    func getVisits(for rescuerId: String, status: VisitStatus?) async throws -> [Visit] {
        var query = supabaseClient
            .from("visits")
            .select()
            .eq("rescuer_id", value: rescuerId)
        
        if let status = status {
            query = query.eq("status", value: status.rawValue)
        }
        
        let response = try await query
            .order("scheduled_date", ascending: true)
            .execute()
        
        let visits = try JSONDecoder().decode([Visit].self, from: response.data)
        return visits
    }
    
    func createVisit(_ visit: CreateVisit) async throws -> Visit {
        struct VisitInsert: Encodable {
            let rescuer_id: String
            let adopter_id: String
            let animal_id: String
            let visit_type: String
            let scheduled_date: String
            let duration_minutes: Int
            let location: String?
            let status: String
            let rescuer_notes: String?
            let requirements: [String]
            let preparation_notes: String?
        }
        
        let newVisit = VisitInsert(
            rescuer_id: visit.rescuerId,
            adopter_id: visit.adopterId,
            animal_id: visit.animalId,
            visit_type: visit.visitType.rawValue,
            scheduled_date: visit.scheduledDate.ISO8601Format(),
            duration_minutes: visit.durationMinutes,
            location: visit.location,
            status: visit.status.rawValue,
            rescuer_notes: visit.rescuerNotes,
            requirements: visit.requirements,
            preparation_notes: visit.preparationNotes
        )
        
        let response = try await supabaseClient
            .from("visits")
            .insert(newVisit)
            .select()
            .execute()
        
        let visits = try JSONDecoder().decode([Visit].self, from: response.data)
        guard let createdVisit = visits.first else {
            throw RescueError.creationFailed
        }
        
        return createdVisit
    }
    
    func updateVisit(_ visit: Visit) async throws -> Visit {
        struct VisitUpdate: Encodable {
            let visit_type: String
            let scheduled_date: String
            let duration_minutes: Int
            let location: String?
            let status: String
            let rescuer_notes: String?
            let adopter_notes: String?
            let outcome: String?
            let requirements: [String]
            let preparation_notes: String?
            let follow_up_required: Bool
            let follow_up_date: String?
        }
        
        let updateData = VisitUpdate(
            visit_type: visit.visitType.rawValue,
            scheduled_date: visit.scheduledDate.ISO8601Format(),
            duration_minutes: visit.durationMinutes,
            location: visit.location,
            status: visit.status.rawValue,
            rescuer_notes: visit.rescuerNotes,
            adopter_notes: visit.adopterNotes,
            outcome: visit.outcome,
            requirements: visit.requirements,
            preparation_notes: visit.preparationNotes,
            follow_up_required: visit.followUpRequired,
            follow_up_date: visit.followUpDate?.ISO8601Format()
        )
        
        let response = try await supabaseClient
            .from("visits")
            .update(updateData)
            .eq("id", value: visit.id)
            .select()
            .execute()
        
        let visits = try JSONDecoder().decode([Visit].self, from: response.data)
        guard let updatedVisit = visits.first else {
            throw RescueError.updateFailed
        }
        
        return updatedVisit
    }
    
    // MARK: - Transactions Management
    
    func getTransactions(for rescuerId: String, dateRange: DateInterval?) async throws -> [Transaction] {
        var query = supabaseClient
            .from("transactions")
            .select()
            .eq("rescuer_id", value: rescuerId)
        
        if let dateRange = dateRange {
            query = query
                .gte("transaction_date", value: dateRange.start.ISO8601Format())
                .lte("transaction_date", value: dateRange.end.ISO8601Format())
        }
        
        let response = try await query
            .order("transaction_date", ascending: false)
            .execute()
        
        let transactions = try JSONDecoder().decode([Transaction].self, from: response.data)
        return transactions
    }
    
    func addTransaction(_ transaction: CreateTransaction) async throws -> Transaction {
        struct TransactionInsert: Encodable {
            let rescuer_id: String
            let visit_id: String?
            let animal_id: String?
            let amount: Double
            let transaction_type: String
            let direction: String
            let payment_method: String?
            let description: String
            let category: String?
            let payer_adopter_id: String?
            let transaction_date: String
            let notes: String?
        }
        
        let newTransaction = TransactionInsert(
            rescuer_id: transaction.rescuerId,
            visit_id: transaction.visitId,
            animal_id: transaction.animalId,
            amount: transaction.amount,
            transaction_type: transaction.transactionType.rawValue,
            direction: transaction.direction.rawValue,
            payment_method: transaction.paymentMethod?.rawValue,
            description: transaction.description,
            category: transaction.category,
            payer_adopter_id: transaction.payerAdopterId,
            transaction_date: transaction.transactionDate.ISO8601Format(),
            notes: transaction.notes
        )
        
        let response = try await supabaseClient
            .from("transactions")
            .insert(newTransaction)
            .select()
            .execute()
        
        let transactions = try JSONDecoder().decode([Transaction].self, from: response.data)
        guard let createdTransaction = transactions.first else {
            throw RescueError.creationFailed
        }
        
        return createdTransaction
    }
    
    // MARK: - Messages Management
    
    func getMessages(for userId: String, animalId: String?) async throws -> [RescueMessage] {
        var query = supabaseClient
            .from("messages")
            .select()
            .or("sender_id.eq.\(userId),recipient_id.eq.\(userId)")
        
        if let animalId = animalId {
            query = query.eq("animal_id", value: animalId)
        }
        
        let response = try await query
            .order("created_at", ascending: false)
            .execute()
        
        let messages = try JSONDecoder().decode([RescueMessage].self, from: response.data)
        return messages
    }
    
    func sendMessage(_ message: CreateMessage) async throws -> RescueMessage {
        struct MessageInsert: Encodable {
            let sender_id: String
            let recipient_id: String
            let animal_id: String?
            let visit_id: String?
            let subject: String?
            let content: String
            let message_type: String
            let priority: String
        }
        
        let newMessage = MessageInsert(
            sender_id: message.senderId,
            recipient_id: message.recipientId,
            animal_id: message.animalId,
            visit_id: message.visitId,
            subject: message.subject,
            content: message.content,
            message_type: message.messageType.rawValue,
            priority: message.priority.rawValue
        )
        
        let response = try await supabaseClient
            .from("messages")
            .insert(newMessage)
            .select()
            .execute()
        
        let messages = try JSONDecoder().decode([RescueMessage].self, from: response.data)
        guard let sentMessage = messages.first else {
            throw RescueError.creationFailed
        }
        
        return sentMessage
    }
    
    func markMessageAsRead(id: String) async throws {
        struct MessageUpdate: Encodable {
            let is_read: Bool
            let read_at: String
        }
        
        let updateData = MessageUpdate(
            is_read: true,
            read_at: Date().ISO8601Format()
        )
        
        try await supabaseClient
            .from("messages")
            .update(updateData)
            .eq("id", value: id)
            .execute()
    }
}

// MARK: - Create Models for API Requests

struct CreateRescuerProfile {
    let organizationName: String?
    let registrationNumber: String?
    let specialties: [String]
    let capacity: Int
    let location: String?
    let contactPhone: String?
    let contactEmail: String?
    let bio: String?
    let websiteUrl: String?
}

struct CreateRescueAnimal {
    let name: String
    let breed: String
    let age: Int
    let size: DogSize
    let gender: DogGender
    let bio: String?
    let location: String
    let traits: [String]
    let energyLevel: EnergyLevel
    let isGoodWithKids: Bool
    let isGoodWithPets: Bool
    let houseTrained: Bool
    let specialNeeds: String?
    let adoptionFee: Double?
    let available: Bool
    let imageUrls: [String]
    let rescueDate: Date?
    let rescueLocation: String?
    let rescueStory: String?
    let medicalStatus: MedicalStatus
    let medicalNotes: String?
    let isSpayedNeutered: Bool
    let weight: Double?
    let rescuerNotes: String?
    let isFeatured: Bool
    let vaccinations: [String: String]?
    let fosterFamilyId: String?
    let documentUrls: [String]
}

struct CreateVisit {
    let rescuerId: String
    let adopterId: String
    let animalId: String
    let visitType: VisitType
    let scheduledDate: Date
    let durationMinutes: Int
    let location: String?
    let status: VisitStatus
    let rescuerNotes: String?
    let requirements: [String]
    let preparationNotes: String?
}

struct CreateTransaction {
    let rescuerId: String
    let visitId: String?
    let animalId: String?
    let amount: Double
    let transactionType: TransactionType
    let direction: TransactionDirection
    let paymentMethod: PaymentMethod?
    let description: String
    let category: String?
    let payerAdopterId: String?
    let transactionDate: Date
    let notes: String?
}

struct CreateMessage {
    let senderId: String
    let recipientId: String
    let animalId: String?
    let visitId: String?
    let subject: String?
    let content: String
    let messageType: MessageType
    let priority: MessagePriority
}

// MARK: - Errors

enum RescueError: LocalizedError {
    case creationFailed
    case updateFailed
    case notFound
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .creationFailed:
            return "Failed to create record"
        case .updateFailed:
            return "Failed to update record"
        case .notFound:
            return "Record not found"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}