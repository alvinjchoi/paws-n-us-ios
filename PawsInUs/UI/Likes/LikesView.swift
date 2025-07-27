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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    switch likedDogs {
                    case .notRequested:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear { loadLikedDogs() }
                    case .isLoading:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .loaded(let dogs):
                        if dogs.isEmpty {
                            emptyLikesView
                        } else {
                            likedDogsGrid(dogs: dogs)
                        }
                    case .failed(let error):
                        ErrorView(error: error, retryAction: loadLikedDogs)
                    }
                }
            }
            .navigationTitle("Likes")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadLikedDogs()
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
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(dogs, id: \.id) { dog in
                NavigationLink(destination: DogDetailView(dog: dog)) {
                    LikedDogCard(dog: dog)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
    
    private func loadLikedDogs() {
        diContainer.interactors.likesInteractor.loadLikedDogs(dogs: $likedDogs)
    }
}

struct LikedDogCard: View {
    let dog: Dog
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Dog image
            if let firstImageURL = dog.imageURLs.first {
                AsyncImage(url: URL(string: firstImageURL)) { image in
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
                .frame(height: 250)
                .clipped()
            }
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.7)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Dog info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(dog.name)
                        .font(.system(size: 20, weight: .bold))
                    Text("\(dog.age)")
                        .font(.system(size: 18, weight: .medium))
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                    Text(dog.location)
                        .font(.system(size: 14))
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .padding(12)
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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