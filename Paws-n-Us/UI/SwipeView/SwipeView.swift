//
//  SwipeView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI
import Supabase
import Combine
import WebKit

struct SwipeView: View {
    @Environment(\.injected) private var diContainer
    @State private var dogs: Loadable<[Dog]> = .notRequested
    @State private var currentIndex = 0
    @State private var dragOffset = CGSize.zero
    @State private var showAction = false
    @State private var swipeAction: SwipeAction = .none
    @State private var checkTimer: Timer?
    @State private var selectedDog: Dog?
    @State private var currentImageIndices: [String: Int] = [:] // Track image index for each dog
    @State private var showingAuth = false
    
    private let swipeThreshold: CGFloat = 100
    private let rotationMultiplier: Double = 0.03
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            // Main content with more space
            content
        }
        .onAppear {
            loadDogs()
        }
        .sheet(item: $selectedDog) { dog in
            DogDetailsView(dog: dog)
        }
        .sheet(isPresented: $showingAuth) {
            AuthView()
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            // Logo section - using separate images for light/dark mode
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
            
            Spacer()
            
            // Right side buttons - commented out
            /*
            HStack(spacing: 16) {
                Button(action: {
                    diContainer.appState[\.routing.selectedTab] = .profile
                }) {
                    Image(systemName: "person.circle")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            */
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
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
            case .isLoading:
                ProgressView()
            case .loaded(let dogsArray):
                if dogsArray.isEmpty || currentIndex >= dogsArray.count {
                    emptyView
                } else {
                    swipeStack(dogs: dogsArray)
                }
            case .failed(let error):
                ErrorView(error: error, retryAction: loadDogs)
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
                    Text("더 이상 표시할 강아지가 없습니다")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("나중에 다시 확인해주세요!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: loadDogs) {
                        Label("새로고침", systemImage: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                    .padding(.top, 10)
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
                        DogCardView(
                            dog: dog, 
                            onInfoTap: {
                                selectedDog = dog
                            },
                            isActive: index == currentIndex,
                            currentImageIndex: binding(for: dog.id)
                        )
                            .frame(width: geometry.size.width - 40, height: geometry.size.height - 80)
                            .aspectRatio(3/4, contentMode: .fit)
                            .offset(y: CGFloat(index - currentIndex) * 10 - 25)
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
                    .zIndex(2000) // Ensure buttons are always on top
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
                        Text("LATER, FRIEND 🥹")
                            .font(.system(size: 32, weight: .bold))
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
                        
                        Text("🥹")
                            .font(.system(size: 32))
                    }
                }
                
                // Like button
                Button(action: { performSwipe(.like) }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 65, height: 65)
                            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 2)
                        
                        if !diContainer.appState[\.userData.isAuthenticated] {
                            // Show lock icon when not authenticated
                            ZStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .offset(x: 8, y: 8)
                            }
                        } else {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                        }
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
                    // Only show action overlay if authenticated or if it's a pass action
                    if diContainer.appState[\.userData.isAuthenticated] || swipeAction == .pass {
                        showAction = true
                    }
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
        
        // Check authentication for likes
        if action == .like && !diContainer.appState[\.userData.isAuthenticated] {
            // Reset the card position
            withAnimation(.spring()) {
                dragOffset = .zero
                showAction = false
                swipeAction = .none
            }
            // Show auth sheet
            showingAuth = true
            return
        }
        
        // Update state immediately, not after animation
        if action == .like {
            diContainer.interactors.dogsInteractor.likeDog(dog)
        } else {
            diContainer.interactors.dogsInteractor.passDog(dog)
        }
        
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = CGSize(
                width: action == .like ? UIScreen.main.bounds.width * 1.5 : -UIScreen.main.bounds.width * 1.5,
                height: 0
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
        // Reset index when loading new dogs
        currentIndex = 0
        diContainer.interactors.dogsInteractor.loadDogs(dogs: $dogs)
    }
    
    private func binding(for dogId: String) -> Binding<Int> {
        Binding<Int>(
            get: { currentImageIndices[dogId] ?? 0 },
            set: { currentImageIndices[dogId] = $0 }
        )
    }
}

enum SwipeAction {
    case none, like, pass
}

struct DogCardView: View {
    let dog: Dog
    let onInfoTap: () -> Void
    let isActive: Bool
    @Binding var currentImageIndex: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background container with fixed size
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    // Background image with fixed aspect ratio
                    Group {
                        if !dog.imageURLs.isEmpty, let url = URL(string: dog.imageURLs[currentImageIndex]) {
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
                            .id("\(dog.id)-\(currentImageIndex)") // Force view update when index changes
                            .transition(.opacity)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Text("No image")
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .clipped()
                )
                
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
                
                // Dog info - positioned higher to avoid button overlap
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .bottom) {
                            HStack(alignment: .bottom, spacing: 8) {
                                Text(dog.name)
                                    .font(.system(size: 30, weight: .bold))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .minimumScaleFactor(0.8)
                                Text("\(dog.age)세")
                                    .font(.system(size: 22, weight: .medium))
                            }
                            .layoutPriority(1)
                            
                            Spacer(minLength: 8)
                            
                            // Info button - commented out since center tap opens details
                            /*
                            Button(action: onInfoTap) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                            }
                            .layoutPriority(2)
                            */
                        }
                        
                        Text(dog.bio)
                            .font(.system(size: 16))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Add spacing to avoid button overlap
                    Color.clear
                        .frame(height: 80)
                }
                
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .overlay(
            // Only show tap areas on active card
            Group {
                if isActive {
                    // Tap areas for navigation - positioned to avoid info button
                    VStack {
                        // Upper portion for photo navigation
                        HStack(spacing: 0) {
                            // Left edge - previous photo
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 80)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if currentImageIndex > 0 {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            currentImageIndex -= 1
                                        }
                                    }
                                }
                                .overlay(
                                    Group {
                                        if dog.imageURLs.count > 1 && currentImageIndex > 0 {
                                            HStack {
                                                Image(systemName: "chevron.left")
                                                    .font(.system(size: 20, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .padding(.leading, 8)
                                                Spacer()
                                            }
                                        }
                                    }
                                )
                            
                            // Center area - show details
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onInfoTap()
                                }
                            
                            // Right edge - next photo
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 80)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if currentImageIndex < dog.imageURLs.count - 1 {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            currentImageIndex += 1
                                        }
                                    }
                                }
                                .overlay(
                                    Group {
                                        if dog.imageURLs.count > 1 && currentImageIndex < dog.imageURLs.count - 1 {
                                            HStack {
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 20, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .padding(.trailing, 8)
                                            }
                                        }
                                    }
                                )
                        }
                        
                        // Bottom area - reduced since no info button
                        Spacer()
                            .frame(height: 120) // Space for text area
                    }
                    .allowsHitTesting(true) // Ensure tap gestures work
                }
            }
        )
    }
}

struct SVGLogoView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        
        if let svgPath = Bundle.main.path(forResource: "pawsinus-logo", ofType: "svg"),
           let svgContent = try? String(contentsOfFile: svgPath, encoding: .utf8) {
            let htmlContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body { margin: 0; padding: 0; background: transparent; display: flex; justify-content: flex-start; align-items: center; height: 100vh; width: 100vw; }
                    svg { width: 100%; height: auto; max-height: 100%; }
                </style>
            </head>
            <body>
                \(svgContent)
            </body>
            </html>
            """
            webView.loadHTMLString(htmlContent, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
}