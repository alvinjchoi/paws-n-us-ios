//
//  VisitsRepository.swift
//  PawsInUs
//
//  Created by Assistant on 1/28/25.
//

import Foundation
import Combine
import Supabase

protocol VisitsRepository: Sendable {
    func createVisit(_ request: CreateVisitRequest) async throws -> Visit
    func getVisitsForRescuer(_ rescuerId: UUID) async throws -> [Visit]
    func getVisitsForAdopter(_ adopterId: String) async throws -> [Visit]
    func getVisitsForAnimal(_ animalId: UUID) async throws -> [Visit]
    func updateVisitStatus(_ visitId: UUID, status: VisitStatus) async throws -> Visit
    func cancelVisit(_ visitId: UUID, reason: String?) async throws -> Visit
    func getVisitsByDate(_ rescuerId: UUID, date: Date) async throws -> [Visit]
    func getVisits(_ rescuerId: UUID) async throws -> [Visit]
}

final class SupabaseVisitsRepository: VisitsRepository, @unchecked Sendable {
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func createVisit(_ request: CreateVisitRequest) async throws -> Visit {
        let visit: Visit = try await client
            .from("visits")
            .insert(request)
            .select()
            .single()
            .execute()
            .value
        
        // Visit created successfully
        return visit
    }
    
    func getVisitsForRescuer(_ rescuerId: UUID) async throws -> [Visit] {
        let visits: [Visit] = try await client
            .from("visits")
            .select()
            .eq("rescuer_id", value: rescuerId)
            .order("scheduled_date", ascending: true)
            .execute()
            .value
        
        // Fetched visits for rescuer
        return visits
    }
    
    func getVisitsForAdopter(_ adopterId: String) async throws -> [Visit] {
        let visits: [Visit] = try await client
            .from("visits")
            .select()
            .eq("adopter_id", value: adopterId)
            .order("scheduled_date", ascending: true)
            .execute()
            .value
        
        // Fetched visits for adopter
        return visits
    }
    
    func getVisitsForAnimal(_ animalId: UUID) async throws -> [Visit] {
        let visits: [Visit] = try await client
            .from("visits")
            .select()
            .eq("animal_id", value: animalId)
            .order("scheduled_date", ascending: true)
            .execute()
            .value
        
        // Fetched visits for animal
        return visits
    }
    
    func updateVisitStatus(_ visitId: UUID, status: VisitStatus) async throws -> Visit {
        let visit: Visit = try await client
            .from("visits")
            .update(["status": status.rawValue])
            .eq("id", value: visitId)
            .select()
            .single()
            .execute()
            .value
        
        // Visit status updated
        return visit
    }
    
    func cancelVisit(_ visitId: UUID, reason: String?) async throws -> Visit {
        struct VisitCancellation: Codable {
            let status: String
            let outcome: String?
        }
        
        let updateData = VisitCancellation(
            status: VisitStatus.cancelled.rawValue,
            outcome: reason != nil ? "Cancelled: \(reason!)" : nil
        )
        
        let visit: Visit = try await client
            .from("visits")
            .update(updateData)
            .eq("id", value: visitId)
            .select()
            .single()
            .execute()
            .value
        
        // Visit cancelled
        return visit
    }
    
    func getVisitsByDate(_ rescuerId: UUID, date: Date) async throws -> [Visit] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let visits: [Visit] = try await client
            .from("visits")
            .select()
            .eq("rescuer_id", value: rescuerId)
            .gte("scheduled_date", value: startOfDay)
            .lt("scheduled_date", value: endOfDay)
            .order("scheduled_date", ascending: true)
            .execute()
            .value
        
        // Fetched visits by date
        return visits
    }
    
    func getVisits(_ rescuerId: UUID) async throws -> [Visit] {
        return try await getVisitsForRescuer(rescuerId)
    }
}