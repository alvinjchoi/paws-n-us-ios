//
//  ProfileView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI

struct ProfileRecord: Codable {
    let id: String
    let name: String?
    let email: String?
    let phone: String?
    let location: String?
    let bio: String?
    let profile_image_url: String?
    let created_at: String?
}

struct NewProfile: Encodable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let location: String
    let bio: String
    let created_at: String
}

struct ProfileView: View {
    @Environment(\.injected) private var diContainer
    @State private var adopter: Adopter?
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingPreferences = false
    @State private var showingAuth = false
    @State private var showingSwitchToRescuing = false
    @State private var showingLikes = false
    @State private var isLoadingProfile = false
    @State private var viewRefreshID = UUID()
    
    var debugState: String {
        "isAuth: \(diContainer.appState[\.userData.isAuthenticated]), isLoading: \(isLoading), adopter: \(adopter?.name ?? "nil")"
    }
    
    var body: some View {
        let _ = print("ProfileView body rendered - \(debugState)")
        NavigationView {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if diContainer.appState[\.userData.isAuthenticated] {
                    ScrollView {
                        VStack {
                            let _ = print("ProfileView body: isAuthenticated=true, adopter=\(adopter?.name ?? "nil"), isLoading=\(isLoading)")
                            
                            if isLoading {
                                VStack {
                                ProgressView()
                                Text("Loading profile...")
                                    .padding()
                            }
                        } else if let adopterProfile = adopter {
                            let _ = print("ProfileView: Showing profile content for \(adopterProfile.name)")
                            profileContent(adopterProfile)
                        } else if let error = error {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                                    .padding()
                                Text("Error loading profile")
                                    .font(.headline)
                                Text(error.localizedDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding()
                                Button("Retry") {
                                    Task {
                                        await loadProfile()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        } else {
                            VStack {
                                ProgressView()
                                Text("Loading profile...")
                                    .padding()
                            }
                            .onAppear { 
                                print("ProfileView: No adopter, calling loadProfile")
                                Task {
                                    await loadProfile()
                                }
                            }
                        }
                        }
                        .id(viewRefreshID)
                    }
                } else {
                    notAuthenticatedView
                }
                
                // Floating button - only show when authenticated
                if diContainer.appState[\.userData.isAuthenticated] {
                    Button(action: {
                        showingSwitchToRescuing = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.swap")
                                .font(.system(size: 18, weight: .medium))
                            Text("구조활동으로 전환")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(30)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if diContainer.appState[\.userData.isAuthenticated] {
                            Button(action: {
                                Task {
                                    await loadProfile()
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingPreferences) {
                    PreferencesView()
                }
                .sheet(isPresented: $showingAuth) {
                    AuthView()
                        .onDisappear {
                            // Refresh profile when auth sheet closes
                            if diContainer.appState[\.userData.isAuthenticated] {
                                Task {
                                    await loadProfile()
                                }
                            }
                        }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingSwitchToRescuing) {
            RescuerModeView()
        }
        .sheet(isPresented: $showingLikes) {
            NavigationView {
                LikesView()
                    .navigationTitle("내가 좋아한 강아지")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("완료") {
                                showingLikes = false
                            }
                        }
                    }
            }
        }
        .task {
            // Check current session status
            let currentSession = diContainer.supabaseClient.auth.currentSession
            print("ProfileView: Current session exists: \(currentSession != nil)")
            if let session = currentSession {
                print("ProfileView: User ID from session: \(session.user.id)")
                print("ProfileView: User phone: \(session.user.phone ?? "nil")")
            }
            
            if diContainer.appState[\.userData.isAuthenticated] && adopter == nil && !isLoading {
                print("ProfileView: App state says authenticated, loading profile...")
                await loadProfile()
            } else {
                print("ProfileView: App state says not authenticated or profile already loading")
            }
        }
        .onReceive(diContainer.appState.updates(for: \.userData.isAuthenticated).removeDuplicates()) { isAuthenticated in
            print("ProfileView: Auth state changed to: \(isAuthenticated)")
            if isAuthenticated && adopter == nil && !isLoading {
                Task {
                    // Small delay to ensure auth state is fully propagated
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    await loadProfile()
                }
            } else if !isAuthenticated {
                // Reset adopter state when logged out
                adopter = nil
                error = nil
            }
        }
    }
    
    @ViewBuilder
    private func profileContent(_ adopter: Adopter) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Profile header with larger avatar
            VStack(spacing: 24) {
                // Avatar
                if let imageURL = adopter.profileImageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(Color(.systemGray3))
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(Color(.systemGray3))
                }
                
                // Name and info
                VStack(spacing: 8) {
                    Text(adopter.name)
                        .font(.system(size: 28, weight: .semibold))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(adopter.location)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            
            // Divider
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
                .padding(.horizontal)
            
            // Stats section with new design
            HStack(spacing: 0) {
                StatItem(
                    value: "\(diContainer.appState[\.userData.likedDogIDs].count)",
                    label: "좋아요"
                )
                
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 1, height: 40)
                
                StatItem(value: "0", label: "방문")
                
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 1, height: 40)
                
                StatItem(value: "0", label: "입양")
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            
            // Another divider
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
                .padding(.horizontal)
            
            // Menu items with Airbnb style
            VStack(spacing: 0) {
                MenuButton(
                    icon: "heart",
                    title: "내가 좋아한 강아지",
                    action: { showingLikes = true }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                MenuButton(
                    icon: "bell",
                    title: "알림 설정",
                    action: { showingPreferences = true }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                MenuButton(
                    icon: "questionmark.circle",
                    title: "도움말",
                    action: { }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                MenuButton(
                    icon: "gearshape",
                    title: "계정 설정",
                    action: { }
                )
            }
            .padding(.top, 24)
            
            // Sign out button
            Button(action: {
                Task {
                    try? await diContainer.interactors.authInteractor.signOut()
                }
            }) {
                Text("로그아웃")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
            }
            .padding(.top, 24)
        }
        
        Spacer()
    }
    
    @MainActor
    private func loadProfile() async {
        guard !isLoadingProfile else {
            print("ProfileView: Already loading profile, skipping")
            return
        }
        
        isLoadingProfile = true
        defer { isLoadingProfile = false }
        
        print("ProfileView: Starting loadProfile()")
        isLoading = true
        error = nil
        
        do {
            print("ProfileView: Getting current user...")
            // Get current user from Supabase
            if let user = try await diContainer.interactors.authInteractor.getCurrentUser() {
                print("ProfileView: Got user: \(user.id), phone: \(user.phone ?? "nil"), email: \(user.email ?? "nil")")
                // Try to load adopter profile
                print("ProfileView: Querying profiles table...")
                let response = try await diContainer.supabaseClient.from("profiles")
                    .select()
                    .eq("id", value: user.id.uuidString.lowercased())
                    .execute()
                
                print("ProfileView: Got response, data length: \(response.data.count)")
                let profileData = response.data
                let profiles = try JSONDecoder().decode([ProfileRecord].self, from: profileData)
                print("ProfileView: Decoded \(profiles.count) profiles")
                
                if let profile = profiles.first {
                    // Profile exists
                    print("ProfileView: Found profile - name: \(profile.name ?? "nil"), location: \(profile.location ?? "nil")")
                    let adopterProfile = Adopter(
                        id: profile.id,
                        name: profile.name ?? "User",
                        email: profile.email ?? user.email ?? user.phone ?? "",
                        location: profile.location ?? "Unknown",
                        bio: profile.bio ?? "",
                        profileImageURL: profile.profile_image_url
                    )
                    
                    print("ProfileView: Setting adopter to loaded state")
                    self.adopter = adopterProfile
                    self.isLoading = false
                    self.viewRefreshID = UUID() // Force view refresh
                    print("ProfileView: State updated - adopter: \(self.adopter?.name ?? "nil"), isLoading: \(self.isLoading)")
                } else {
                    // No profile exists, create one for phone users
                    let phoneNumber = user.phone ?? ""
                    let displayName = phoneNumber.isEmpty ? "User" : "User \(phoneNumber.suffix(4))"
                    
                    print("ProfileView: No profile found, creating new one...")
                    
                    // Try to create a new profile
                    do {
                        let newProfile = NewProfile(
                            id: user.id.uuidString.lowercased(),
                            name: displayName,
                            email: user.email ?? "",
                            phone: phoneNumber,
                            location: "Seoul",
                            bio: "",
                            created_at: ISO8601DateFormatter().string(from: Date())
                        )
                        
                        try await diContainer.supabaseClient.from("profiles")
                            .insert(newProfile)
                            .execute()
                        
                        print("ProfileView: Successfully created new profile")
                    } catch {
                        print("ProfileView: Failed to create profile in database: \(error)")
                        // Continue anyway - we'll show a basic profile
                    }
                    
                    // Create adopter object regardless of database insert success
                    let adopterProfile = Adopter(
                        id: user.id.uuidString.lowercased(),
                        name: displayName,
                        email: user.email ?? phoneNumber,
                        location: "Seoul",
                        bio: "",
                        profileImageURL: nil
                    )
                    
                    print("ProfileView: Setting adopter to loaded state (new profile)")
                    self.adopter = adopterProfile
                    self.isLoading = false
                    self.viewRefreshID = UUID() // Force view refresh
                }
            } else {
                struct AuthError: LocalizedError {
                    var errorDescription: String? { "Authentication required" }
                }
                error = AuthError()
                isLoading = false
            }
        } catch {
            print("ProfileView: Profile loading error: \(error)")
            print("ProfileView: Error type: \(type(of: error))")
            print("ProfileView: Error localized: \(error.localizedDescription)")
            self.error = error
            isLoading = false
        }
    }
    
    private var notAuthenticatedView: some View {
        VStack(spacing: 0) {
            // Header area
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 80))
                    .foregroundColor(Color(.systemGray3))
                    .padding(.top, 60)
                
                VStack(spacing: 12) {
                    Text("로그인하여 프로필 확인하기")
                        .font(.system(size: 24, weight: .semibold))
                    
                    Text("좋아하는 강아지를 저장하고\n입양 신청을 관리하세요")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)
            
            // Divider
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 8)
            
            // Sign in button
            VStack(spacing: 16) {
                Button(action: {
                    showingAuth = true
                }) {
                    Text("로그인")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                HStack(spacing: 4) {
                    Text("계정이 없으신가요?")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showingAuth = true
                    }) {
                        Text("회원가입")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                            .underline()
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold))
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Preferences Settings")
                .navigationTitle("Preferences")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}