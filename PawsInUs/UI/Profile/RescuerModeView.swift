//
//  RescuerModeView.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI

struct RescuerModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var selectedTab = 0
    
    var body: some View {
        if isLoading {
            // Loading state
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // House illustration placeholder
                    Image(systemName: "house.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.orange.opacity(0.8))
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .offset(x: -10, y: 10)
                        )
                    
                    Text("구조활동으로 전환 중")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
            .onAppear {
                // Simulate loading
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        } else {
            // Rescuer Dashboard
            TabView(selection: $selectedTab) {
                // Today Tab
                TodayView()
                    .tabItem {
                        Label("오늘", systemImage: "calendar.badge.clock")
                    }
                    .tag(0)
                
                // Calendar Tab
                CalendarView()
                    .tabItem {
                        Label("캘린더", systemImage: "calendar")
                    }
                    .tag(1)
                
                // Listings Tab
                ListingsView()
                    .tabItem {
                        Label("보호 동물", systemImage: "square.grid.2x2")
                    }
                    .tag(2)
                
                // Messages Tab
                MessagesView()
                    .tabItem {
                        Label("메시지", systemImage: "message")
                    }
                    .tag(3)
                
                // Menu Tab
                MenuView()
                    .tabItem {
                        Label("메뉴", systemImage: "line.3.horizontal")
                    }
                    .tag(4)
            }
        }
    }
}

// MARK: - Today View
struct TodayView: View {
    @Environment(\.injected) private var diContainer
    @State private var selectedSegment = 0
    @State private var todayVisits: [VisitDTO] = []
    @State private var upcomingVisits: [VisitDTO] = []
    @State private var isLoading = true
    @State private var dogs: [String: Dog] = [:]
    
    var body: some View {
        NavigationView {
            VStack {
                // Segment Control
                Picker("", selection: $selectedSegment) {
                    Text("오늘").tag(0)
                    Text("예정").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    if selectedSegment == 0 {
                        // Today content
                        if todayVisits.isEmpty {
                            VStack(spacing: 30) {
                                Spacer()
                                
                                Image(systemName: "book.closed")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("예약이 없습니다")
                                    .font(.title)
                                    .fontWeight(.medium)
                                
                                Text("오늘 예정된 놀이 시간이나 방문이 없습니다")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(todayVisits, id: \.id) { visit in
                                        VisitCard(visit: visit, dog: dogs[visit.animalID])
                                    }
                                }
                                .padding()
                            }
                        }
                    } else {
                        // Upcoming content
                        if upcomingVisits.isEmpty {
                            VStack(spacing: 30) {
                                Spacer()
                                
                                Image(systemName: "calendar")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("예정된 방문이 없습니다")
                                    .font(.title)
                                    .fontWeight(.medium)
                                
                                Text("앞으로 예정된 놀이 시간이나 방문이 없습니다")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(upcomingVisits, id: \.id) { visit in
                                        VisitCard(visit: visit, dog: dogs[visit.animalID])
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("오늘")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6))
            .onAppear {
                loadVisits()
            }
            .refreshable {
                await loadVisitsAsync()
            }
        }
    }
    
    private func loadVisits() {
        Task {
            await loadVisitsAsync()
        }
    }
    
    private func loadVisitsAsync() async {
        isLoading = true
        
        do {
            // Get current user ID - in real app, rescuer ID would be used
            guard let userID = diContainer.appState[\.userData.currentUserID] else {
                isLoading = false
                return
            }
            
            let visitsRepo = diContainer.repositories.visitsRepository
            
            // Load today's visits
            todayVisits = try await visitsRepo.getVisitsByDate(rescuerID: userID, date: Date())
            
            // Load all visits and filter for upcoming
            let allVisits = try await visitsRepo.getVisits(for: userID)
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            let startOfTomorrow = Calendar.current.startOfDay(for: tomorrow)
            
            upcomingVisits = allVisits.filter { visit in
                if let date = ISO8601DateFormatter().date(from: visit.scheduledDate) {
                    return date >= startOfTomorrow
                }
                return false
            }
            
            // Load dog information for all visits
            let dogIDs = Set((todayVisits + upcomingVisits).map { $0.animalID })
            await loadDogs(dogIDs: Array(dogIDs))
            
            isLoading = false
        } catch {
            print("Error loading visits: \(error)")
            isLoading = false
        }
    }
    
    private func loadDogs(dogIDs: [String]) async {
        let dogsRepo = diContainer.repositories.dogsRepository
        
        for dogID in dogIDs {
            do {
                let dog = try await dogsRepo.getDog(by: dogID)
                dogs[dogID] = dog
            } catch {
                print("Error loading dog \(dogID): \(error)")
            }
        }
    }
}

struct VisitCard: View {
    let visit: VisitDTO
    let dog: Dog?
    
    private var visitTypeText: String {
        switch visit.visitType {
        case "meet_greet":
            return "놀이 시간"
        case "adoption_interview":
            return "입양 상담"
        case "home_visit":
            return "가정 방문"
        default:
            return "방문"
        }
    }
    
    private var visitTypeIcon: String {
        switch visit.visitType {
        case "meet_greet":
            return "figure.play"
        case "adoption_interview":
            return "heart.fill"
        case "home_visit":
            return "house.fill"
        default:
            return "calendar"
        }
    }
    
    private var visitTypeColor: Color {
        switch visit.visitType {
        case "meet_greet":
            return .blue
        case "adoption_interview":
            return .red
        case "home_visit":
            return .green
        default:
            return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: visitTypeIcon)
                    .font(.system(size: 20))
                    .foregroundColor(visitTypeColor)
                
                Text(visitTypeText)
                    .font(.headline)
                    .foregroundColor(visitTypeColor)
                
                Spacer()
                
                Text(formatTime(visit.scheduledDate))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            // Dog info
            if let dog = dog {
                HStack(spacing: 12) {
                    if let imageURL = dog.imageURLs.first, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dog.name)
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(dog.breed) • \(dog.age)세")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Status
            HStack {
                Image(systemName: "mappin.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text(visit.location ?? "위치 미정")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(statusText(visit.status ?? "scheduled"))
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(statusColor(visit.status ?? "scheduled").opacity(0.2))
                    .foregroundColor(statusColor(visit.status ?? "scheduled"))
                    .cornerRadius(12)
            }
            
            // Notes if available
            if let notes = visit.adopterNotes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func formatTime(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: date)
    }
    
    private func statusText(_ status: String) -> String {
        switch status {
        case "scheduled":
            return "예정됨"
        case "confirmed":
            return "확정됨"
        case "in_progress":
            return "진행 중"
        case "completed":
            return "완료됨"
        case "cancelled":
            return "취소됨"
        case "no_show":
            return "노쇼"
        default:
            return status
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "scheduled", "confirmed":
            return .blue
        case "in_progress":
            return .orange
        case "completed":
            return .green
        case "cancelled", "no_show":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    @Environment(\.injected) private var diContainer
    @State private var selectedDate = Date()
    @State private var visits: [VisitDTO] = []
    @State private var visitsByDate: [String: [VisitDTO]] = [:]
    @State private var dogs: [String: Dog] = [:]
    @State private var isLoading = true
    @State private var selectedVisit: VisitDTO?
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                
                // Calendar grid
                CalendarGridView(
                    selectedDate: $selectedDate,
                    visitsByDate: visitsByDate,
                    onDateSelected: { date in
                        selectedDate = date
                    }
                )
                
                Divider()
                
                // Visits for selected date
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    let dateKey = dateKey(for: selectedDate)
                    let visitsForDate = visitsByDate[dateKey] ?? []
                    
                    if visitsForDate.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("이 날짜에 예정된 방문이 없습니다")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(visitsForDate, id: \.id) { visit in
                                    VisitCard(visit: visit, dog: dogs[visit.animalID])
                                        .onTapGesture {
                                            selectedVisit = visit
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("캘린더")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadVisits()
            }
            .sheet(item: $selectedVisit) { visit in
                VisitDetailSheet(visit: visit, dog: dogs[visit.animalID])
            }
        }
    }
    
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        loadVisits()
    }
    
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        loadVisits()
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MMMM"
        return formatter.string(from: date)
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func loadVisits() {
        Task {
            isLoading = true
            
            do {
                guard let userID = diContainer.appState[\.userData.currentUserID] else {
                    isLoading = false
                    return
                }
                
                let visitsRepo = diContainer.repositories.visitsRepository
                visits = try await visitsRepo.getVisits(for: userID)
                
                // Group visits by date
                visitsByDate = [:]
                for visit in visits {
                    if let date = ISO8601DateFormatter().date(from: visit.scheduledDate) {
                        let key = dateKey(for: date)
                        if visitsByDate[key] == nil {
                            visitsByDate[key] = []
                        }
                        visitsByDate[key]?.append(visit)
                    }
                }
                
                // Load dog information
                let dogIDs = Set(visits.map { $0.animalID })
                await loadDogs(dogIDs: Array(dogIDs))
                
                isLoading = false
            } catch {
                print("Error loading visits: \(error)")
                isLoading = false
            }
        }
    }
    
    private func loadDogs(dogIDs: [String]) async {
        let dogsRepo = diContainer.repositories.dogsRepository
        
        for dogID in dogIDs {
            do {
                let dog = try await dogsRepo.getDog(by: dogID)
                dogs[dogID] = dog
            } catch {
                print("Error loading dog \(dogID): \(error)")
            }
        }
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let visitsByDate: [String: [VisitDTO]]
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack(spacing: 10) {
            // Weekday headers
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar days
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            hasVisits: hasVisits(on: date),
                            visitCount: visitCount(on: date)
                        ) {
                            onDateSelected(date)
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: selectedDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        let numberOfDays = monthRange.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        // Fill out the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasVisits(on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        return visitsByDate[key] != nil && !visitsByDate[key]!.isEmpty
    }
    
    private func visitCount(on date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        return visitsByDate[key]?.count ?? 0
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasVisits: Bool
    let visitCount: Int
    let onTap: () -> Void
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor, lineWidth: isToday ? 2 : 0)
                    )
                
                VStack(spacing: 4) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(textColor)
                    
                    if hasVisits {
                        HStack(spacing: 2) {
                            ForEach(0..<min(visitCount, 3), id: \.self) { _ in
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }
            }
            .frame(height: 40)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.blue
        } else if hasVisits {
            return Color.blue.opacity(0.1)
        } else {
            return Color(.secondarySystemBackground)
        }
    }
    
    private var borderColor: Color {
        isToday ? Color.orange : Color.clear
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else {
            return .primary
        }
    }
}

struct VisitDetailSheet: View {
    let visit: VisitDTO
    let dog: Dog?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Visit type header
                    HStack {
                        Image(systemName: visitTypeIcon)
                            .font(.title)
                            .foregroundColor(visitTypeColor)
                        
                        Text(visitTypeText)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    
                    // Dog info
                    if let dog = dog {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("동물 정보")
                                .font(.headline)
                            
                            HStack(spacing: 16) {
                                if let imageURL = dog.imageURLs.first, let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dog.name)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Text("\(dog.breed) • \(dog.age)세")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                    
                    // Visit details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(icon: "calendar", title: "날짜", value: formatDate(visit.scheduledDate))
                        DetailRow(icon: "clock", title: "시간", value: formatTime(visit.scheduledDate))
                        DetailRow(icon: "mappin.circle", title: "위치", value: visit.location ?? "위치 미정")
                        DetailRow(icon: "person.2", title: "상태", value: statusText(visit.status ?? "scheduled"))
                        
                        if let notes = visit.adopterNotes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("메모", systemImage: "note.text")
                                    .font(.headline)
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var visitTypeText: String {
        switch visit.visitType {
        case "meet_greet":
            return "놀이 시간"
        case "adoption_interview":
            return "입양 상담"
        case "home_visit":
            return "가정 방문"
        default:
            return "방문"
        }
    }
    
    private var visitTypeIcon: String {
        switch visit.visitType {
        case "meet_greet":
            return "figure.play"
        case "adoption_interview":
            return "heart.fill"
        case "home_visit":
            return "house.fill"
        default:
            return "calendar"
        }
    }
    
    private var visitTypeColor: Color {
        switch visit.visitType {
        case "meet_greet":
            return .blue
        case "adoption_interview":
            return .red
        case "home_visit":
            return .green
        default:
            return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
    
    private func formatTime(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: date)
    }
    
    private func statusText(_ status: String) -> String {
        switch status {
        case "scheduled":
            return "예정됨"
        case "confirmed":
            return "확정됨"
        case "in_progress":
            return "진행 중"
        case "completed":
            return "완료됨"
        case "cancelled":
            return "취소됨"
        case "no_show":
            return "노쇼"
        default:
            return status
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Listings View
struct ListingsView: View {
    @Environment(\.injected) private var diContainer
    @State private var dogs: [Dog] = []
    @State private var isLoading = true
    @State private var error: Error?
    @State private var showingAddAnimal = false
    @State private var selectedDog: Dog?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    VStack {
                        ProgressView()
                        Text("동물 목록을 불러오는 중...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("동물 목록을 불러올 수 없습니다")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Button("다시 시도") {
                            loadDogs()
                        }
                        .padding()
                    }
                } else if dogs.isEmpty {
                    emptyStateView
                } else {
                    dogsList(dogs)
                }
            }
            .navigationTitle("보호 동물")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddAnimal = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                loadDogs()
            }
            .refreshable {
                await loadDogsAsync()
            }
        }
        .sheet(isPresented: $showingAddAnimal) {
            AddDogView()
                .environment(\.injected, diContainer)
                .onDisappear {
                    loadDogs()
                }
        }
        .sheet(item: $selectedDog) { dog in
            DogManagementDetailView(dog: dog)
                .environment(\.injected, diContainer)
                .onDisappear {
                    loadDogs()
                }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "pawprint.2")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 12) {
                Text("아직 보호 중인 동물이 없습니다")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("첫 번째 보호 동물을 등록해보세요")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                showingAddAnimal = true
            }) {
                Label("새 동물 등록", systemImage: "plus.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(25)
            }
            .disabled(currentRescuer == nil)
            
            Spacer()
        }
        .padding()
    }
    
    private func dogsList(_ dogs: [Dog]) -> some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(dogs) { dog in
                    DogManagementCard(dog: dog) {
                        selectedDog = dog
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
    
    private func loadDogs() {
        Task {
            await loadDogsAsync()
        }
    }
    
    private func loadDogsAsync() async {
        isLoading = true
        error = nil
        
        do {
            // Get current user ID - in real app would filter by rescuer
            guard let userID = diContainer.appState[\.userData.currentUserID] else {
                dogs = []
                isLoading = false
                return
            }
            
            let dogsRepo = diContainer.repositories.dogsRepository
            
            // For now, load all dogs from Supabase
            // In production, you'd filter by rescuer_id
            dogs = try await dogsRepo.getDogs()
            
            // Filter to show only dogs from sample data that would belong to this rescuer
            // This is temporary - in production, the database query would handle this
            dogs = dogs.filter { dog in
                // Show dogs from specific shelters as example
                ["서울동물복지지원센터 마포", "서울동물복지지원센터 구로", "서울동물복지지원센터 동대문"].contains(dog.shelterName)
            }
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}

struct DogManagementCard: View {
    let dog: Dog
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                if let imageURL = dog.imageURLs.first, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(height: 160)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 160)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(dog.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(dog.breed) • \(dog.age)세")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(formatDate(dog.dateAdded))
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.gray)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// Placeholder views for add and detail - these would need full implementation
struct AddDogView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("동물 추가 기능은 아직 구현되지 않았습니다")
                .navigationTitle("새 동물 등록")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("취소") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct DogManagementDetailView: View {
    let dog: Dog
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image carousel
                    TabView {
                        ForEach(dog.imageURLs, id: \.self) { imageURL in
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(ProgressView())
                            }
                            .frame(height: 300)
                            .clipped()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 300)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Basic info
                        Text(dog.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label("\(dog.breed)", systemImage: "pawprint")
                            Spacer()
                            Label("\(dog.age)세", systemImage: "calendar")
                        }
                        .font(.body)
                        
                        Divider()
                        
                        // Bio
                        Text("소개")
                            .font(.headline)
                        Text(dog.bio)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Status
                        HStack {
                            Label("상태", systemImage: "info.circle")
                                .font(.headline)
                            Spacer()
                            Text("입양 가능")
                                .font(.body)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(12)
                        }
                        .padding(.top)
                        
                        // Actions
                        VStack(spacing: 12) {
                            Button(action: {}) {
                                Label("정보 수정", systemImage: "pencil")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {}) {
                                Label("삭제", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .foregroundColor(.red)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("동물 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Messages View
struct MessagesView: View {
    @Environment(\.injected) private var diContainer
    @State private var messages: [MessageDBDTO] = []
    @State private var isLoading = true
    @State private var selectedMessage: MessageDBDTO?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if messages.isEmpty {
                    VStack {
                        Image(systemName: "envelope")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.bottom, 16)
                        
                        Text("메시지가 없습니다")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("입양 신청이나 놀이 시간 요청이 있으면 여기에 표시됩니다")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 8)
                        
                        Spacer()
                    }
                    .padding(.top, 100)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages, id: \.id) { message in
                                MessageRow(message: message)
                                    .onTapGesture {
                                        selectedMessage = message
                                        if !(message.isRead ?? false) {
                                            markAsRead(message.id)
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("메시지")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadMessages()
            }
            .refreshable {
                await loadMessagesAsync()
            }
            .sheet(item: $selectedMessage) { message in
                MessageDetailView(message: message)
                    .environment(\.injected, diContainer)
            }
        }
    }
    
    private func loadMessages() {
        Task {
            await loadMessagesAsync()
        }
    }
    
    private func loadMessagesAsync() async {
        isLoading = true
        
        do {
            // Get current user ID - in real app, rescuer ID would be used
            guard let userID = diContainer.appState[\.userData.currentUserID] else {
                isLoading = false
                return
            }
            
            let messagesRepo = diContainer.repositories.messagesRepository
            messages = try await messagesRepo.getMessages(for: userID)
            isLoading = false
        } catch {
            print("Error loading messages: \(error)")
            isLoading = false
        }
    }
    
    private func markAsRead(_ messageID: String) {
        Task {
            do {
                let messagesRepo = diContainer.repositories.messagesRepository
                try await messagesRepo.markMessageAsRead(messageID)
                
                // Update local state
                if let index = messages.firstIndex(where: { $0.id == messageID }) {
                    messages[index] = MessageDBDTO(
                        id: messages[index].id,
                        senderID: messages[index].senderID,
                        recipientID: messages[index].recipientID,
                        animalID: messages[index].animalID,
                        visitID: messages[index].visitID,
                        subject: messages[index].subject,
                        content: messages[index].content,
                        messageType: messages[index].messageType,
                        isRead: true,
                        readAt: ISO8601DateFormatter().string(from: Date()),
                        priority: messages[index].priority,
                        attachmentURLs: messages[index].attachmentURLs,
                        createdAt: messages[index].createdAt,
                        updatedAt: messages[index].updatedAt
                    )
                }
            } catch {
                print("Error marking message as read: \(error)")
            }
        }
    }
}

struct MessageRow: View {
    let message: MessageDBDTO
    
    private var typeIcon: String {
        switch message.messageType {
        case "adoption_inquiry":
            return "heart.fill"
        case "visit_request":
            return "calendar"
        default:
            return "envelope"
        }
    }
    
    private var typeColor: Color {
        switch message.messageType {
        case "adoption_inquiry":
            return .red
        case "visit_request":
            return .blue
        default:
            return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: typeIcon)
                .font(.system(size: 24))
                .foregroundColor(typeColor)
                .frame(width: 40, height: 40)
                .background(typeColor.opacity(0.1))
                .clipShape(Circle())
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(message.subject ?? "메시지")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(message.content)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(formatDate(message.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Unread indicator
            if !(message.isRead ?? false) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.locale = Locale(identifier: "ko_KR")
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
}

struct MessageDetailView: View {
    let message: MessageDBDTO
    @Environment(\.dismiss) private var dismiss
    @Environment(\.injected) private var diContainer
    @State private var dog: Dog?
    @State private var isLoadingDog = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.subject ?? "메시지")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(formatDate(message.createdAt))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Dog info if available
                    if let animalID = message.animalID {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("관련 동물")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if isLoadingDog {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if let dog = dog {
                                HStack(spacing: 12) {
                                    if let imageURL = dog.imageURLs.first, let url = URL(string: imageURL) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                        }
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(dog.name)
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("\(dog.breed) • \(dog.age)세")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .onAppear {
                            loadDog(animalID)
                        }
                    }
                    
                    Divider()
                    
                    // Message content
                    Text(message.content)
                        .font(.body)
                        .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func loadDog(_ dogID: String) {
        Task {
            do {
                let dogsRepo = diContainer.repositories.dogsRepository
                dog = try await dogsRepo.getDog(by: dogID)
                isLoadingDog = false
            } catch {
                print("Error loading dog: \(error)")
                isLoadingDog = false
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

// MARK: - Menu View
struct MenuView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Earnings section
                HStack {
                    VStack(alignment: .leading) {
                        Text("수익")
                            .font(.headline)
                        Text("2025년 1월")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("₩0")
                            .font(.system(size: 36, weight: .bold))
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("인사이트")
                            .font(.headline)
                        Text("아직 리뷰가 없습니다")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star")
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding()
                
                // Menu Items
                VStack(spacing: 0) {
                    MenuRow(icon: "gearshape", title: "계정 설정")
                    Divider().padding(.leading, 60)
                    
                    MenuRow(icon: "doc.text", title: "구조 활동 자료")
                    Divider().padding(.leading, 60)
                    
                    MenuRow(icon: "questionmark.circle", title: "도움말")
                    Divider().padding(.leading, 60)
                    
                    MenuRow(icon: "person.2", title: "공동 구조자 찾기")
                    Divider().padding(.leading, 60)
                    
                    MenuRow(icon: "plus.app", title: "새 보호 동물 등록")
                    Divider().padding(.leading, 60)
                    
                    MenuRow(icon: "person.badge.plus", title: "친구 추천")
                    Divider().padding(.leading, 60)
                    
                    MenuRow(icon: "doc.plaintext", title: "법적 정보")
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Switch back button
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.swap")
                            .font(.system(size: 18, weight: .medium))
                        Text("일반 모드로 전환")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .cornerRadius(30)
                }
                .padding()
            }
            .navigationTitle("메뉴")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6))
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 22))
                .frame(width: 30)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 17))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    RescuerModeView()
}