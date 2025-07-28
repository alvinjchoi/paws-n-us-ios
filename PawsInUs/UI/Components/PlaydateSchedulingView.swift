//
//  PlaydateSchedulingView.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI

struct PlaydateSchedulingView: View {
    let dog: Dog
    @Environment(\.dismiss) private var dismiss
    @Environment(\.injected) private var diContainer
    @State private var selectedGuests = 1
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: String?
    @State private var showingConfirmation = false
    @State private var isSubmitting = false
    
    private let guestOptions = [1, 2, 3, 4, 5, 6]
    private let timeSlots = [
        "9:00 AM", "9:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM",
        "12:00 PM", "12:30 PM", "1:00 PM", "1:30 PM", "2:00 PM", "2:30 PM",
        "3:00 PM", "3:30 PM", "4:00 PM", "4:30 PM", "5:00 PM"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with dog info
                VStack(spacing: 16) {
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
                        .frame(height: 200)
                        .clipped()
                    }
                    
                    VStack(spacing: 8) {
                        Text("\(dog.name)와 놀이 시간 예약")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(dog.shelterName)에서")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Guests section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("인원")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(guestOptions, id: \.self) { count in
                                        Button(action: {
                                            selectedGuests = count
                                        }) {
                                            Text("\(count)")
                                                .font(.system(size: 18, weight: .medium))
                                                .frame(width: 60, height: 60)
                                                .background(selectedGuests == count ? Color.blue : Color(.systemGray5))
                                                .foregroundColor(selectedGuests == count ? .white : .primary)
                                                .clipShape(Circle())
                                        }
                                    }
                                    
                                    Button(action: {
                                        selectedGuests = 7
                                    }) {
                                        Text("7+")
                                            .font(.system(size: 18, weight: .medium))
                                            .frame(width: 60, height: 60)
                                            .background(selectedGuests >= 7 ? Color.blue : Color(.systemGray5))
                                            .foregroundColor(selectedGuests >= 7 ? .white : .primary)
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Date section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("날짜")
                                    .font(.headline)
                                Spacer()
                                DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                                    .labelsHidden()
                            }
                            .padding(.horizontal)
                        }
                        
                        // Time section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("시간")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(timeSlots, id: \.self) { timeSlot in
                                    Button(action: {
                                        selectedTimeSlot = timeSlot
                                    }) {
                                        Text(timeSlot)
                                            .font(.system(size: 14, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 44)
                                            .background(selectedTimeSlot == timeSlot ? Color.blue : Color(.systemGray5))
                                            .foregroundColor(selectedTimeSlot == timeSlot ? .white : .primary)
                                            .cornerRadius(22)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 24)
                }
                
                // Bottom button
                VStack {
                    Button(action: {
                        if selectedTimeSlot != nil {
                            Task {
                                await submitPlaydateRequest()
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
                            Text("놀이 시간 신청")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(selectedTimeSlot != nil ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(28)
                        }
                    }
                    .disabled(selectedTimeSlot == nil || isSubmitting)
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
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
        .alert("놀이 시간 신청 완료!", isPresented: $showingConfirmation) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("\(dog.shelterName)에 놀이 시간 신청이 전송되었습니다. 곧 확인 연락을 드릴 예정입니다!")
        }
    }
    
    private func submitPlaydateRequest() async {
        isSubmitting = true
        
        do {
            // Get current user ID
            guard let userID = diContainer.appState[\.userData.currentAdopterID] else {
                print("No user ID found")
                isSubmitting = false
                return
            }
            
            // Get the rescuer ID for this dog (we'll need to fetch this from the dogs table)
            let dogsRepo = diContainer.repositories.dogsRepository
            let dog = try await dogsRepo.getDog(by: dog.id)
            
            // For now, we'll use the shelter_id as the recipient_id
            // In a real app, you'd need to fetch the rescuer associated with this dog
            let recipientID = dog.shelterID
            
            // Create scheduled date with time
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            
            // Parse time slot
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let timeSlot = selectedTimeSlot,
               let time = timeFormatter.date(from: timeSlot) {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
            }
            
            let scheduledDate = calendar.date(from: dateComponents) ?? selectedDate
            let dateFormatter = ISO8601DateFormatter()
            
            // Create message
            let messageRepo = diContainer.repositories.messagesRepository
            let message = MessageDBDTO(
                id: UUID().uuidString,
                senderID: userID,
                recipientID: recipientID,
                animalID: dog.id,
                visitID: nil,
                subject: "놀이 시간 신청 - \(dog.name)",
                content: "안녕하세요! \(dog.name)와의 놀이 시간을 신청합니다.\n\n날짜: \(DateFormatter.localizedString(from: selectedDate, dateStyle: .long, timeStyle: .none))\n시간: \(selectedTimeSlot ?? "")\n인원: \(selectedGuests)명",
                messageType: "visit_request",
                isRead: false,
                readAt: nil,
                priority: "normal",
                attachmentURLs: [],
                createdAt: dateFormatter.string(from: Date()),
                updatedAt: dateFormatter.string(from: Date())
            )
            
            try await messageRepo.createMessage(message)
            
            // Create visit
            let visitsRepo = diContainer.repositories.visitsRepository
            let visit = VisitDTO(
                id: UUID().uuidString,
                rescuerID: recipientID, // Using shelter ID as rescuer ID for now
                adopterID: userID,
                animalID: dog.id,
                visitType: "meet_greet",
                scheduledDate: dateFormatter.string(from: scheduledDate),
                durationMinutes: 60,
                location: dog.location,
                status: "scheduled",
                rescuerNotes: nil,
                adopterNotes: "인원: \(selectedGuests)명",
                outcome: nil,
                requirements: [],
                preparationNotes: nil,
                followUpRequired: false,
                followUpDate: nil,
                createdAt: dateFormatter.string(from: Date()),
                updatedAt: dateFormatter.string(from: Date())
            )
            
            try await visitsRepo.createVisit(visit)
            
            isSubmitting = false
            showingConfirmation = true
            
        } catch {
            print("Error submitting playdate request: \(error)")
            isSubmitting = false
        }
    }
}