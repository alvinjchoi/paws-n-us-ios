//
//  LikesView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI

struct LikesView: View {
    @Environment(\.injected) private var diContainer
    @State private var likedDogs: Loadable<[Dog]> = .notRequested
    @State private var showingAuth = false
    @State private var isCurrentlyLoading = false
    
    var isAuthenticated: Bool {
        // Temporarily return true to test likes functionality
        // TODO: Restore proper auth check: diContainer.appState.value.userData.isAuthenticated
        true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                if isAuthenticated {
                    ScrollView {
                        switch likedDogs {
                        case .notRequested:
                            VStack {
                                ProgressView()
                                Text("Not requested yet")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear { loadLikedDogs() }
                        case .isLoading:
                            VStack {
                                ProgressView()
                                Text("Loading liked dogs...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .loaded(let dogs):
                            VStack {
                                if dogs.isEmpty {
                                    emptyLikesView
                                } else {
                                    likedDogsGrid(dogs: dogs)
                                }
                            }
                            .onAppear {
                                isCurrentlyLoading = false
                                // Preload all images for better performance
                                ImagePreloader.preloadDogImages(dogs)
                            }
                        case .failed(let error):
                            VStack {
                                ErrorView(error: error, retryAction: loadLikedDogs)
                                Text("Error: \(error.localizedDescription)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            .onAppear {
                                isCurrentlyLoading = false
                            }
                        }
                    }
                    .padding(.bottom, 20) // Add extra bottom padding for tab bar
                } else {
                    notAuthenticatedView
                }
            }
            .navigationTitle("Likes")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if isAuthenticated && likedDogs == .notRequested {
                    loadLikedDogs()
                }
            }
            .onReceive(diContainer.appState.updates(for: \.userData.likedDogIDs)) { _ in
                if isAuthenticated && !isCurrentlyLoading {
                    loadLikedDogs()
                }
            }
            .sheet(isPresented: $showingAuth) {
                AuthView()
                    .environment(\.injected, diContainer)
            }
        }
    }
    
    private var emptyLikesView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 100)
            
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No likes yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Start swiping to find dogs you love!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                diContainer.appState[\.routing.selectedTab] = .discover
            }) {
                Text("Start Swiping")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 150, height: 44)
                    .background(Color.orange)
                    .cornerRadius(22)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func likedDogsGrid(dogs: [Dog]) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 16) {
            ForEach(dogs, id: \.id) { dog in
                NavigationLink(destination: DogDetailView(dog: dog)) {
                    LikedDogCard(dog: dog)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20) // Extra bottom padding for last card
    }
    
    private func loadLikedDogs() {
        guard !isCurrentlyLoading else {
            return
        }
        
        let currentLikedIDs = Array(diContainer.appState.value.userData.likedDogIDs)
        
        isCurrentlyLoading = true
        diContainer.interactors.likesInteractor.loadLikedDogs(dogs: $likedDogs)
        
        // Reset loading flag after timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            if isCurrentlyLoading {
                isCurrentlyLoading = false
            }
        }
    }
    
    private var notAuthenticatedView: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 50)
            
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 10) {
                Text("Sign in to Save Your Likes")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Create an account to save your favorite dogs and connect with shelters")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    showingAuth = true
                }) {
                    Text("Sign In / Sign Up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    diContainer.appState[\.routing.selectedTab] = .discover
                }) {
                    Text("Continue Browsing")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
    }
}

struct LikedDogCard: View {
    let dog: Dog
    @Environment(\.injected) private var diContainer
    
    var body: some View {
        VStack(spacing: 0) {
            // Dog image with proper corner radius
            ZStack(alignment: .topTrailing) {
                if let firstImageURL = dog.imageURLs.first, let url = URL(string: firstImageURL) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                    .frame(height: 160)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                Text("No image")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                        .frame(height: 160)
                }
                
                // Heart button
                Button(action: {
                    diContainer.interactors.likesInteractor.unlikeDog(dog)
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(6)
                        .background(Circle().fill(Color.white.opacity(0.95)))
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding(8)
            }
            
            // Dog info section
            VStack(alignment: .leading, spacing: 6) {
                Text(dog.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Text("\(dog.age)세")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Text("•")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Text(dog.breed)
                        .font(.system(size: 13))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.secondary)
                }
                
                Text(dog.shelterName)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .frame(minHeight: 240) // Ensure minimum height for cards
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

struct DogDetailView: View {
    let dog: Dog
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
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
                        .frame(height: 400)
                        .clipped()
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 400)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Name and age
                    HStack(alignment: .bottom) {
                        Text(dog.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("\(dog.age) years old")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    // Breed and location
                    VStack(alignment: .leading, spacing: 8) {
                        Label(dog.breed, systemImage: "pawprint")
                        Label(dog.location, systemImage: "location")
                    }
                    .font(.body)
                    
                    Divider()
                    
                    // Bio
                    Text("About \(dog.name)")
                        .font(.headline)
                    Text(dog.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // Traits
                    if !dog.traits.isEmpty {
                        Text("Personality")
                            .font(.headline)
                            .padding(.top)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(dog.traits, id: \.self) { trait in
                                Text(trait)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .cornerRadius(15)
                            }
                        }
                    }
                    
                    // Additional info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Additional Information")
                            .font(.headline)
                            .padding(.top)
                        
                        HStack {
                            Image(systemName: "figure.2.and.child.holdinghands")
                            Text(dog.isGoodWithKids ? "Good with kids" : "Not suitable for kids")
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "dog")
                            Text(dog.isGoodWithPets ? "Good with other pets" : "Prefers to be only pet")
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "bolt")
                            Text("Energy level: \(dog.energyLevel.rawValue)")
                            Spacer()
                        }
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                    
                    // Contact button
                    Button(action: {
                        // Handle contact shelter
                    }) {
                        Text("Contact \(dog.shelterName)")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }
}