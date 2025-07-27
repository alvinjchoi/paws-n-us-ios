//
//  SwipeView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI
import Supabase
import Combine

struct SwipeView: View {
    @Environment(\.injected) private var diContainer
    @State private var dogs: Loadable<[Dog]> = .notRequested
    @State private var currentIndex = 0
    @State private var dragOffset = CGSize.zero
    @State private var showAction = false
    @State private var swipeAction: SwipeAction = .none
    @State private var shouldLoad = false
    @State private var checkTimer: Timer?
    
    private let swipeThreshold: CGFloat = 100
    private let rotationMultiplier: Double = 0.03
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                headerView
                
                // Main content
                content
                    .padding(.top, 10)
            }
        }
        .onAppear {
            print("🎯 SwipeView appeared")
            shouldLoad = true
        }
        .onChange(of: shouldLoad) { oldValue, newValue in
            if newValue {
                print("📱 Loading dogs from SwipeView")
                loadDogs()
                shouldLoad = false
            }
        }
        .onChange(of: dogs) { oldValue, newValue in
            print("🔄 Dogs state changed from \(oldValue) to \(newValue)")
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "pawprint.fill")
                .font(.title)
                .foregroundColor(.orange)
            
            Text("pawsinus")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                diContainer.appState[\.routing.selectedTab] = .profile
            }) {
                Image(systemName: "person.circle")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                diContainer.appState[\.routing.selectedTab] = .likes
            }) {
                Image(systemName: "heart.circle")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var content: some View {
        ZStack {
            // Background to maintain layout
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            switch dogs {
            case .notRequested:
                ProgressView()
                    .onAppear { print("📊 State: notRequested") }
            case .isLoading:
                ProgressView()
                    .onAppear { print("📊 State: isLoading") }
            case .loaded(let dogsArray):
                if dogsArray.isEmpty {
                    emptyView
                        .onAppear { print("📊 State: loaded but empty") }
                } else {
                    swipeStack(dogs: dogsArray)
                        .onAppear { print("📊 State: loaded with \(dogsArray.count) dogs") }
                }
            case .failed(let error):
                ErrorView(error: error, retryAction: loadDogs)
                    .onAppear { print("📊 State: failed with \(error)") }
            }
        }
    }
    
    private var emptyView: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No more dogs to show")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Check back later for more furry friends!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                // Empty space for where buttons would be
                Color.clear
                    .frame(height: 100)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func swipeStack(dogs: [Dog]) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Render cards in reverse order so the current card is on top
                ForEach(Array(dogs.enumerated().reversed()), id: \.element.id) { index, dog in
                    if index >= currentIndex && index < currentIndex + 3 {
                        DogCardView(dog: dog)
                            .frame(width: geometry.size.width - 40, height: geometry.size.height - 120)
                            .offset(y: CGFloat(index - currentIndex) * 10)
                            .scaleEffect(index == currentIndex ? 1 : 0.95 - CGFloat(index - currentIndex) * 0.02)
                            .opacity(index == currentIndex ? 1 : 0.9)
                            .offset(index == currentIndex ? dragOffset : .zero)
                            .rotationEffect(.degrees(Double(dragOffset.width) * rotationMultiplier))
                            .animation(.spring(), value: dragOffset)
                            .gesture(
                                index == currentIndex ? dragGesture : nil
                            )
                            .overlay(
                                overlayView
                                    .opacity(index == currentIndex && showAction ? 1 : 0)
                            )
                            .zIndex(index == currentIndex ? 1000 : Double(1000 - (index - currentIndex)))
                    }
                }
                
                actionButtons
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private var overlayView: some View {
        ZStack {
            if swipeAction == .like {
                VStack {
                    HStack {
                        Spacer()
                        Text("LIKE")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.green)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 4)
                            )
                            .rotationEffect(.degrees(-20))
                            .padding(.top, 30)
                            .padding(.trailing, 20)
                    }
                    Spacer()
                }
            } else if swipeAction == .pass {
                VStack {
                    HStack {
                        Text("NOPE")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.red)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 4)
                            )
                            .rotationEffect(.degrees(20))
                            .padding(.top, 30)
                            .padding(.leading, 20)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack {
            Spacer()
            HStack(spacing: 40) {
                // Pass button
                Button(action: { performSwipe(.pass) }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 65, height: 65)
                            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 2)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
                
                // Like button
                Button(action: { performSwipe(.like) }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 65, height: 65)
                            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 2)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                
                if abs(value.translation.width) > swipeThreshold {
                    swipeAction = value.translation.width > 0 ? .like : .pass
                    showAction = true
                } else {
                    showAction = false
                }
            }
            .onEnded { value in
                if abs(value.translation.width) > swipeThreshold {
                    performSwipe(value.translation.width > 0 ? .like : .pass)
                } else {
                    withAnimation(.spring()) {
                        dragOffset = .zero
                        showAction = false
                        swipeAction = .none
                    }
                }
            }
    }
    
    private func performSwipe(_ action: SwipeAction) {
        guard case .loaded(let dogs) = self.dogs,
              currentIndex < dogs.count else { return }
        
        let dog = dogs[currentIndex]
        
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = CGSize(
                width: action == .like ? UIScreen.main.bounds.width * 1.5 : -UIScreen.main.bounds.width * 1.5,
                height: 0
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if action == .like {
                diContainer.interactors.dogsInteractor.likeDog(dog)
            } else {
                diContainer.interactors.dogsInteractor.passDog(dog)
            }
            
            currentIndex += 1
            dragOffset = .zero
            showAction = false
            swipeAction = .none
            
            if currentIndex >= dogs.count {
                loadDogs()
            }
        }
    }
    
    private func loadDogs() {
        diContainer.interactors.dogsInteractor.loadDogs(dogs: $dogs)
    }
}

enum SwipeAction {
    case none, like, pass
}

struct DogCardView: View {
    let dog: Dog
    @State private var currentImageIndex = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image
            if !dog.imageURLs.isEmpty {
                AsyncImage(url: URL(string: dog.imageURLs[currentImageIndex])) { image in
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
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text("No image")
                            .foregroundColor(.white)
                    )
            }
                
                // Image indicators at top
                if dog.imageURLs.count > 1 {
                    VStack {
                        HStack(spacing: 4) {
                            ForEach(0..<dog.imageURLs.count, id: \.self) { index in
                                Rectangle()
                                    .fill(currentImageIndex == index ? Color.white : Color.white.opacity(0.5))
                                    .frame(height: 3)
                                    .cornerRadius(1.5)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                }
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.clear,
                        Color.black.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Dog info
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .bottom) {
                        Text(dog.name)
                            .font(.system(size: 32, weight: .bold))
                        Text("\(dog.age)")
                            .font(.system(size: 26, weight: .medium))
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text(dog.bio)
                        .font(.system(size: 16))
                        .lineLimit(2)
                }
                .foregroundColor(.white)
                .padding()
                
                // Tap areas for image navigation
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if currentImageIndex > 0 {
                                currentImageIndex -= 1
                            }
                        }
                    
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if currentImageIndex < dog.imageURLs.count - 1 {
                                currentImageIndex += 1
                            }
                        }
                }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}