//
//  ProfileView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.injected) private var diContainer
    @State private var adopter: Loadable<Adopter> = .notRequested
    @State private var showingPreferences = false
    
    var body: some View {
        ScrollView {
            switch adopter {
            case .notRequested:
                ProgressView()
                    .onAppear { loadProfile() }
            case .isLoading:
                ProgressView()
            case .loaded(let adopterProfile):
                profileContent(adopterProfile)
            case .failed(let error):
                ErrorView(error: error, retryAction: loadProfile)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingPreferences) {
            PreferencesView()
        }
    }
    
    private func profileContent(_ adopter: Adopter) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Profile header
            HStack(spacing: 20) {
                if let imageURL = adopter.profileImageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(adopter.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(adopter.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(adopter.location)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Settings section
            VStack(spacing: 0) {
                Text("Settings")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                VStack(spacing: 1) {
                    // Preferences
                    Button(action: {
                        showingPreferences = true
                    }) {
                        HStack {
                            Label("Preferences", systemImage: "slider.horizontal.3")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                    
                    Divider()
                        .padding(.leading)
                    
                    // Edit Profile
                    Button(action: {
                        // Handle edit profile
                    }) {
                        HStack {
                            Label("Edit Profile", systemImage: "person.circle")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                    
                    Divider()
                        .padding(.leading)
                    
                    // Sign Out
                    Button(action: {
                        diContainer.interactors.authInteractor.signOut()
                    }) {
                        HStack {
                            Label("Sign Out", systemImage: "arrow.right.square")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding(.top, 30)
            
            Spacer(minLength: 50)
        }
    }
    
    private func loadProfile() {
        diContainer.interactors.adopterInteractor.loadProfile(adopter: $adopter)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
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