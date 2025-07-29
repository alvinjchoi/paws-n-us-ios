//
//  AdoptionApplicationView.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI

struct AdoptionApplicationView: View {
    let dog: Dog
    @Environment(\.dismiss) private var dismiss
    @Environment(\.injected) private var diContainer
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var hasYard = false
    @State private var hasOtherPets = false
    @State private var otherPetsDescription = ""
    @State private var experience = ""
    @State private var whyAdopt = ""
    @State private var showingConfirmation = false
    @State private var isSubmitting = false
    
    var isFormValid: Bool {
        !fullName.isEmpty && !email.isEmpty && !phone.isEmpty && !address.isEmpty && !whyAdopt.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with dog info
                    VStack(spacing: 12) {
                        if let imageURL = dog.imageURLs.first, let url = URL(string: imageURL) {
                            CachedAsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(ProgressView())
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        }
                        
                        Text("\(dog.name) 입양 신청")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(dog.shelterName)에서")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Form sections
                    VStack(spacing: 32) {
                        // Personal Information
                        VStack(alignment: .leading, spacing: 20) {
                            Text("개인 정보")
                                .font(.headline)
                            
                            VStack(spacing: 16) {
                                FormField(title: "이름", text: $fullName)
                                FormField(title: "이메일", text: $email, keyboardType: .emailAddress)
                                FormField(title: "전화번호", text: $phone, keyboardType: .phonePad)
                                FormField(title: "주소", text: $address)
                            }
                        }
                        
                        // Living Situation
                        VStack(alignment: .leading, spacing: 20) {
                            Text("주거 환경")
                                .font(.headline)
                            
                            Toggle(isOn: $hasYard) {
                                Text("마당이 있습니다")
                            }
                            
                            Toggle(isOn: $hasOtherPets) {
                                Text("다른 반려동물이 있습니다")
                            }
                            
                            if hasOtherPets {
                                FormField(
                                    title: "다른 반려동물에 대해 설명해주세요",
                                    text: $otherPetsDescription,
                                    isMultiline: true
                                )
                            }
                        }
                        
                        // Experience
                        VStack(alignment: .leading, spacing: 20) {
                            Text("경험 & 동기")
                                .font(.headline)
                            
                            FormField(
                                title: "강아지와 함께한 경험",
                                text: $experience,
                                isMultiline: true
                            )
                            
                            FormField(
                                title: "\(dog.name)를 입양하고 싶은 이유",
                                text: $whyAdopt,
                                isMultiline: true
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Submit button
                    Button(action: {
                        if isFormValid {
                            Task {
                                await submitAdoptionApplication()
                            }
                        }
                    }) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.gray)
                                .cornerRadius(28)
                        } else {
                            Text("신청서 제출")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(isFormValid ? Color.orange : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(28)
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("입양 신청서")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .alert("신청서 제출 완료!", isPresented: $showingConfirmation) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("\(dog.name) 입양 신청서가 \(dog.shelterName)에 전송되었습니다. 2-3일 내에 검토 후 연락드리겠습니다.")
        }
    }
    
    private func submitAdoptionApplication() async {
        isSubmitting = true
        
        do {
            // Get current user ID
            guard let userID = diContainer.appState[\.userData.currentAdopterID] else {
                // No user ID found
                isSubmitting = false
                return
            }
            
            // Get the rescuer ID for this dog
            let dogsRepo = diContainer.repositories.dogsRepository
            let dog = try await dogsRepo.getDog(by: dog.id)
            
            // For now, we'll use the shelter_id as the recipient_id
            let recipientID = dog.shelterID
            
            let dateFormatter = ISO8601DateFormatter()
            
            // Create adoption application message
            let messageRepo = diContainer.repositories.messagesRepository
            
            let applicationContent = """
            입양 신청서 - \(dog.name)
            
            신청자 정보:
            이름: \(fullName)
            이메일: \(email)
            전화번호: \(phone)
            주소: \(address)
            
            주거 환경:
            마당 여부: \(hasYard ? "있음" : "없음")
            다른 반려동물: \(hasOtherPets ? "있음" : "없음")
            \(hasOtherPets ? "다른 반려동물 설명: \(otherPetsDescription)" : "")
            
            경험 및 동기:
            반려동물 경험: \(experience.isEmpty ? "없음" : experience)
            
            입양 동기:
            \(whyAdopt)
            """
            
            let message = MessageDBDTO(
                id: UUID().uuidString,
                senderID: userID,
                recipientID: recipientID,
                animalID: dog.id,
                visitID: nil,
                subject: "입양 신청 - \(dog.name)",
                content: applicationContent,
                messageType: "adoption_inquiry",
                isRead: false,
                readAt: nil,
                priority: "high",
                attachmentURLs: [],
                createdAt: dateFormatter.string(from: Date()),
                updatedAt: dateFormatter.string(from: Date())
            )
            
            try await messageRepo.createMessage(message)
            
            isSubmitting = false
            showingConfirmation = true
            
        } catch {
            // Error submitting adoption application
            isSubmitting = false
        }
    }
}

struct FormField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            } else {
                TextField("", text: $text)
                    .keyboardType(keyboardType)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
    }
}