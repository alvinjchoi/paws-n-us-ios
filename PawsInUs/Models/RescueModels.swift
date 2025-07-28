//
//  RescueModels.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import Foundation

// MARK: - Rescuer Model
struct Rescuer: Codable, Identifiable {
    let id: String
    let userId: String
    let organizationName: String?
    let registrationNumber: String?
    let verificationStatus: VerificationStatus
    let specialties: [String]
    let capacity: Int
    let currentCount: Int
    let location: String?
    let contactPhone: String?
    let contactEmail: String?
    let bio: String?
    let websiteUrl: String?
    let socialMedia: [String: String]
    let earningsTotal: Double
    let rating: Double
    let reviewCount: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
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
        case websiteUrl = "website_url"
        case socialMedia = "social_media"
        case earningsTotal = "earnings_total"
        case rating
        case reviewCount = "review_count"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = ISO8601DateFormatter()
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        organizationName = try container.decodeIfPresent(String.self, forKey: .organizationName)
        registrationNumber = try container.decodeIfPresent(String.self, forKey: .registrationNumber)
        verificationStatus = try container.decode(VerificationStatus.self, forKey: .verificationStatus)
        specialties = try container.decode([String].self, forKey: .specialties)
        capacity = try container.decode(Int.self, forKey: .capacity)
        currentCount = try container.decode(Int.self, forKey: .currentCount)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        contactPhone = try container.decodeIfPresent(String.self, forKey: .contactPhone)
        contactEmail = try container.decodeIfPresent(String.self, forKey: .contactEmail)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        websiteUrl = try container.decodeIfPresent(String.self, forKey: .websiteUrl)
        socialMedia = try container.decode([String: String].self, forKey: .socialMedia)
        earningsTotal = try container.decode(Double.self, forKey: .earningsTotal)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        
        // Handle date fields
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        } else {
            updatedAt = Date()
        }
    }
}

enum VerificationStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case verified = "verified"
    case rejected = "rejected"
    
    var displayName: String {
        switch self {
        case .pending: return "승인 대기 중"
        case .verified: return "승인됨"
        case .rejected: return "거부됨"
        }
    }
}

// MARK: - Rescue Animal Model (Extended Dog)
struct RescueAnimal: Codable, Identifiable {
    let id: String
    let rescuerId: String?
    let name: String
    let breed: String
    let age: Int
    let size: DogSize
    let gender: DogGender
    let imageUrls: [String]
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
    
    // Rescue-specific fields
    let rescueDate: Date?
    let rescueLocation: String?
    let rescueStory: String?
    let medicalStatus: MedicalStatus
    let medicalNotes: String?
    let isSpayedNeutered: Bool
    let vaccinations: [String: String]?
    let weight: Double?
    let fosterFamilyId: String?
    let documentUrls: [String]
    let rescuerNotes: String?
    let isFeatured: Bool
    
    let shelterName: String?
    let shelterId: String?
    let dateAdded: Date
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, breed, age, size, gender, bio, location, traits
        case energyLevel = "energy_level"
        case isGoodWithKids = "good_with_kids"
        case isGoodWithPets = "good_with_pets"
        case houseTrained = "house_trained"
        case specialNeeds = "special_needs"
        case adoptionFee = "adoption_fee"
        case available
        case imageUrls = "image_urls"
        case rescuerId = "rescuer_id"
        case rescueDate = "rescue_date"
        case rescueLocation = "rescue_location"
        case rescueStory = "rescue_story"
        case medicalStatus = "medical_status"
        case medicalNotes = "medical_notes"
        case isSpayedNeutered = "is_spayed_neutered"
        case vaccinations
        case weight
        case fosterFamilyId = "foster_family_id"
        case documentUrls = "document_urls"
        case rescuerNotes = "rescuer_notes"
        case isFeatured = "is_featured"
        case shelterName = "shelter_name"
        case shelterId = "shelter_id"
        case dateAdded = "date_added"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = ISO8601DateFormatter()
        
        id = try container.decode(String.self, forKey: .id)
        rescuerId = try container.decodeIfPresent(String.self, forKey: .rescuerId)
        name = try container.decode(String.self, forKey: .name)
        breed = try container.decode(String.self, forKey: .breed)
        age = try container.decode(Int.self, forKey: .age)
        size = try container.decode(DogSize.self, forKey: .size)
        gender = try container.decode(DogGender.self, forKey: .gender)
        imageUrls = try container.decodeIfPresent([String].self, forKey: .imageUrls) ?? []
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        location = try container.decode(String.self, forKey: .location)
        traits = try container.decodeIfPresent([String].self, forKey: .traits) ?? []
        energyLevel = try container.decode(EnergyLevel.self, forKey: .energyLevel)
        isGoodWithKids = try container.decode(Bool.self, forKey: .isGoodWithKids)
        isGoodWithPets = try container.decode(Bool.self, forKey: .isGoodWithPets)
        houseTrained = try container.decode(Bool.self, forKey: .houseTrained)
        specialNeeds = try container.decodeIfPresent(String.self, forKey: .specialNeeds)
        adoptionFee = try container.decodeIfPresent(Double.self, forKey: .adoptionFee)
        available = try container.decode(Bool.self, forKey: .available)
        
        // Handle rescue date
        if let rescueDateString = try container.decodeIfPresent(String.self, forKey: .rescueDate) {
            rescueDate = dateFormatter.date(from: rescueDateString)
        } else {
            rescueDate = nil
        }
        
        rescueLocation = try container.decodeIfPresent(String.self, forKey: .rescueLocation)
        rescueStory = try container.decodeIfPresent(String.self, forKey: .rescueStory)
        medicalStatus = try container.decode(MedicalStatus.self, forKey: .medicalStatus)
        medicalNotes = try container.decodeIfPresent(String.self, forKey: .medicalNotes)
        isSpayedNeutered = try container.decode(Bool.self, forKey: .isSpayedNeutered)
        vaccinations = try container.decodeIfPresent([String: String].self, forKey: .vaccinations)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        fosterFamilyId = try container.decodeIfPresent(String.self, forKey: .fosterFamilyId)
        documentUrls = try container.decodeIfPresent([String].self, forKey: .documentUrls) ?? []
        rescuerNotes = try container.decodeIfPresent(String.self, forKey: .rescuerNotes)
        isFeatured = try container.decode(Bool.self, forKey: .isFeatured)
        
        shelterName = try container.decodeIfPresent(String.self, forKey: .shelterName)
        shelterId = try container.decodeIfPresent(String.self, forKey: .shelterId)
        
        // Handle date fields
        if let dateAddedString = try container.decodeIfPresent(String.self, forKey: .dateAdded) {
            dateAdded = dateFormatter.date(from: dateAddedString) ?? Date()
        } else {
            dateAdded = Date()
        }
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        } else {
            updatedAt = Date()
        }
    }
    
    init(
        id: String,
        rescuerId: String?,
        name: String,
        breed: String,
        age: Int,
        size: DogSize,
        gender: DogGender,
        imageUrls: [String],
        bio: String?,
        location: String,
        traits: [String],
        energyLevel: EnergyLevel,
        isGoodWithKids: Bool,
        isGoodWithPets: Bool,
        houseTrained: Bool,
        specialNeeds: String?,
        adoptionFee: Double?,
        available: Bool,
        rescueDate: Date?,
        rescueLocation: String?,
        rescueStory: String?,
        medicalStatus: MedicalStatus,
        medicalNotes: String?,
        isSpayedNeutered: Bool,
        vaccinations: [String: String]?,
        weight: Double?,
        fosterFamilyId: String?,
        documentUrls: [String],
        rescuerNotes: String?,
        isFeatured: Bool,
        shelterName: String?,
        shelterId: String?,
        dateAdded: Date,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.rescuerId = rescuerId
        self.name = name
        self.breed = breed
        self.age = age
        self.size = size
        self.gender = gender
        self.imageUrls = imageUrls
        self.bio = bio
        self.location = location
        self.traits = traits
        self.energyLevel = energyLevel
        self.isGoodWithKids = isGoodWithKids
        self.isGoodWithPets = isGoodWithPets
        self.houseTrained = houseTrained
        self.specialNeeds = specialNeeds
        self.adoptionFee = adoptionFee
        self.available = available
        self.rescueDate = rescueDate
        self.rescueLocation = rescueLocation
        self.rescueStory = rescueStory
        self.medicalStatus = medicalStatus
        self.medicalNotes = medicalNotes
        self.isSpayedNeutered = isSpayedNeutered
        self.vaccinations = vaccinations
        self.weight = weight
        self.fosterFamilyId = fosterFamilyId
        self.documentUrls = documentUrls
        self.rescuerNotes = rescuerNotes
        self.isFeatured = isFeatured
        self.shelterName = shelterName
        self.shelterId = shelterId
        self.dateAdded = dateAdded
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum MedicalStatus: String, Codable, CaseIterable {
    case healthy = "healthy"
    case needsTreatment = "needs_treatment"
    case recovering = "recovering"
    case specialNeeds = "special_needs"
    
    var displayName: String {
        switch self {
        case .healthy: return "건강함"
        case .needsTreatment: return "치료 필요"
        case .recovering: return "회복 중"
        case .specialNeeds: return "특별 관리 필요"
        }
    }
    
    var color: String {
        switch self {
        case .healthy: return "green"
        case .needsTreatment: return "red"
        case .recovering: return "orange"
        case .specialNeeds: return "blue"
        }
    }
}

// MARK: - Visit Model
struct Visit: Codable, Identifiable, Equatable {
    let id: UUID
    let rescuerId: UUID
    let adopterId: String
    let animalId: UUID
    let visitType: VisitType
    let scheduledDate: Date
    let durationMinutes: Int
    let location: String?
    let status: VisitStatus
    let rescuerNotes: String?
    let adopterNotes: String?
    let outcome: String?
    let requirements: [String]
    let preparationNotes: String?
    let followUpRequired: Bool
    let followUpDate: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case rescuerId = "rescuer_id"
        case adopterId = "adopter_id"
        case animalId = "animal_id"
        case visitType = "visit_type"
        case scheduledDate = "scheduled_date"
        case durationMinutes = "duration_minutes"
        case location, status
        case rescuerNotes = "rescuer_notes"
        case adopterNotes = "adopter_notes"
        case outcome, requirements
        case preparationNotes = "preparation_notes"
        case followUpRequired = "follow_up_required"
        case followUpDate = "follow_up_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum VisitType: String, Codable, CaseIterable {
    case meetGreet = "meet_greet"
    case adoptionInterview = "adoption_interview"
    case homeVisit = "home_visit"
    case followUp = "follow_up"
    
    var displayName: String {
        switch self {
        case .meetGreet: return "놀이 시간"
        case .adoptionInterview: return "입양 상담"
        case .homeVisit: return "가정 방문"
        case .followUp: return "후속 방문"
        }
    }
}

enum VisitStatus: String, Codable, CaseIterable {
    case scheduled = "scheduled"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"
    
    var displayName: String {
        switch self {
        case .scheduled: return "예약됨"
        case .confirmed: return "확정됨"
        case .inProgress: return "진행 중"
        case .completed: return "완료됨"
        case .cancelled: return "취소됨"
        case .noShow: return "미참석"
        }
    }
}

// MARK: - Visit Creation Request
struct CreateVisitRequest: Codable {
    let rescuerId: UUID
    let adopterId: String
    let animalId: UUID
    let visitType: VisitType
    let scheduledDate: Date
    let durationMinutes: Int
    let location: String?
    let adopterNotes: String?
    let requirements: [String]
    
    enum CodingKeys: String, CodingKey {
        case rescuerId = "rescuer_id"
        case adopterId = "adopter_id"
        case animalId = "animal_id"
        case visitType = "visit_type"
        case scheduledDate = "scheduled_date"
        case durationMinutes = "duration_minutes"
        case location
        case adopterNotes = "adopter_notes"
        case requirements
    }
}

// MARK: - Transaction Model
struct Transaction: Codable, Identifiable {
    let id: String
    let rescuerId: String
    let visitId: String?
    let animalId: String?
    let amount: Double
    let transactionType: TransactionType
    let direction: TransactionDirection
    let paymentMethod: PaymentMethod?
    let paymentStatus: PaymentStatus
    let referenceNumber: String?
    let description: String
    let category: String?
    let payerAdopterId: String?
    let transactionDate: Date
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case rescuerId = "rescuer_id"
        case visitId = "visit_id"
        case animalId = "animal_id"
        case amount
        case transactionType = "transaction_type"
        case direction
        case paymentMethod = "payment_method"
        case paymentStatus = "payment_status"
        case referenceNumber = "reference_number"
        case description, category
        case payerAdopterId = "payer_adopter_id"
        case transactionDate = "transaction_date"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case adoptionFee = "adoption_fee"
    case donation = "donation"
    case medicalExpense = "medical_expense"
    case foodExpense = "food_expense"
    case serviceFee = "service_fee"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .adoptionFee: return "입양비"
        case .donation: return "후원금"
        case .medicalExpense: return "의료비"
        case .foodExpense: return "사료비"
        case .serviceFee: return "서비스 수수료"
        case .other: return "기타"
        }
    }
}

enum TransactionDirection: String, Codable, CaseIterable {
    case income = "income"
    case expense = "expense"
    
    var displayName: String {
        switch self {
        case .income: return "수입"
        case .expense: return "지출"
        }
    }
}

enum PaymentMethod: String, Codable, CaseIterable {
    case cash = "cash"
    case card = "card"
    case bankTransfer = "bank_transfer"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .cash: return "현금"
        case .card: return "카드"
        case .bankTransfer: return "계좌이체"
        case .other: return "기타"
        }
    }
}

enum PaymentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
    
    var displayName: String {
        switch self {
        case .pending: return "대기 중"
        case .completed: return "완료됨"
        case .failed: return "실패됨"
        case .refunded: return "환불됨"
        }
    }
}

// MARK: - Message Model
struct RescueMessage: Codable, Identifiable {
    let id: String
    let senderId: String
    let recipientId: String
    let animalId: String?
    let visitId: String?
    let subject: String?
    let content: String
    let messageType: MessageType
    let isRead: Bool
    let readAt: Date?
    let priority: MessagePriority
    let attachmentUrls: [String]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case recipientId = "recipient_id"
        case animalId = "animal_id"
        case visitId = "visit_id"
        case subject, content
        case messageType = "message_type"
        case isRead = "is_read"
        case readAt = "read_at"
        case priority
        case attachmentUrls = "attachment_urls"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum MessageType: String, Codable, CaseIterable {
    case general = "general"
    case adoptionInquiry = "adoption_inquiry"
    case visitRequest = "visit_request"
    case followUp = "follow_up"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .general: return "일반"
        case .adoptionInquiry: return "입양 문의"
        case .visitRequest: return "방문 요청"
        case .followUp: return "후속 연락"
        case .urgent: return "긴급"
        }
    }
}

enum MessagePriority: String, Codable, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .low: return "낮음"
        case .normal: return "보통"
        case .high: return "높음"
        case .urgent: return "긴급"
        }
    }
}