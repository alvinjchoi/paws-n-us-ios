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
    @State private var selectedSegment = 0
    
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
                
                if selectedSegment == 0 {
                    // Today content
                    VStack(spacing: 30) {
                        Spacer()
                        
                        Image(systemName: "book.closed")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("예약이 없습니다")
                            .font(.title)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                } else {
                    // Upcoming content
                    VStack(spacing: 30) {
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("예정된 방문이 없습니다")
                            .font(.title)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("오늘")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6))
        }
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("캘린더")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("캘린더")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Listings View
struct ListingsView: View {
    @Environment(\.injected) private var diContainer
    @State private var rescueAnimals: Loadable<[RescueAnimal]> = .notRequested
    @State private var currentRescuer: Rescuer?
    @State private var showingAddAnimal = false
    @State private var showingAnimalDetail: RescueAnimal?
    
    var body: some View {
        NavigationView {
            VStack {
                switch rescueAnimals {
                case .notRequested, .isLoading:
                    VStack {
                        ProgressView()
                        Text("동물 목록을 불러오는 중...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .loaded(let animals):
                    if animals.isEmpty {
                        emptyStateView
                    } else {
                        animalsList(animals)
                    }
                    
                case .failed(let error):
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
                            loadRescueAnimals()
                        }
                        .padding()
                    }
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
                    .disabled(currentRescuer == nil)
                }
            }
        }
        .task {
            await loadCurrentRescuer()
            loadRescueAnimals()
        }
        .sheet(isPresented: $showingAddAnimal) {
            AddRescueAnimalView()
                .onDisappear {
                    loadRescueAnimals()
                }
        }
        .sheet(item: $showingAnimalDetail) { animal in
            RescueAnimalDetailView(animal: animal)
                .onDisappear {
                    loadRescueAnimals()
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
    
    private func animalsList(_ animals: [RescueAnimal]) -> some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(animals) { animal in
                    RescueAnimalCard(animal: animal) {
                        showingAnimalDetail = animal
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
    
    private func loadRescueAnimals() {
        guard let rescuer = currentRescuer else { return }
        
        rescueAnimals = .isLoading(last: nil, cancelBag: CancelBag())
        
        Task {
            do {
                let animals = try await diContainer.interactors.rescueInteractor.getRescueAnimals(for: rescuer.id)
                await MainActor.run {
                    rescueAnimals = .loaded(animals)
                }
            } catch {
                await MainActor.run {
                    rescueAnimals = .failed(error)
                }
            }
        }
    }
    
    @MainActor
    private func loadCurrentRescuer() async {
        do {
            currentRescuer = try await diContainer.interactors.rescueInteractor.getCurrentRescuer()
            
            // If no rescuer profile exists, create a basic one
            if currentRescuer == nil {
                let basicProfile = CreateRescuerProfile(
                    organizationName: nil,
                    registrationNumber: nil,
                    specialties: [],
                    capacity: 5,
                    location: nil,
                    contactPhone: nil,
                    contactEmail: nil,
                    bio: nil,
                    websiteUrl: nil
                )
                
                currentRescuer = try await diContainer.interactors.rescueInteractor.createRescuerProfile(basicProfile)
            }
        } catch {
            print("Failed to load or create rescuer profile: \(error)")
        }
    }
}

// MARK: - Messages View
struct MessagesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("메시지가 없습니다")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("메시지")
            .navigationBarTitleDisplayMode(.large)
        }
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