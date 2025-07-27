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
    @State private var shouldLoad = false
    @State private var checkTimer: Timer?
    @State private var selectedDog: Dog?
    
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
                    .padding(.top, 20)
            }
        }
        .onAppear {
            shouldLoad = true
        }
        .onChange(of: shouldLoad) { oldValue, newValue in
            if newValue {
                loadDogs()
                shouldLoad = false
            }
        }
        .sheet(item: $selectedDog) { dog in
            DogDetailView(dog: dog)
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            // Logo section - positioned more to the left
            if Bundle.main.path(forResource: "pawsinus-logo", ofType: "svg") != nil {
                SVGLogoView()
                    .frame(width: 160, height: 48)
                    .clipped()
                    .offset(x: -20)
            } else {
                // Fallback to pawprint + text
                HStack(spacing: 8) {
                    Image(systemName: "pawprint.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("Paws-N-Us")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // Right side buttons
            HStack(spacing: 16) {
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
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .onAppear {
            let logoPath = Bundle.main.path(forResource: "pawsinus-logo", ofType: "svg")
        }
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
                if dogsArray.isEmpty {
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
                        DogCardView(dog: dog, onInfoTap: {
                            selectedDog = dog
                        })
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
        diContainer.interactors.dogsInteractor.loadDogs(dogs: $dogs)
    }
}

enum SwipeAction {
    case none, like, pass
}

struct DogCardView: View {
    let dog: Dog
    let onInfoTap: () -> Void
    @State private var currentImageIndex = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background container with fixed size
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    // Background image with fixed aspect ratio
                    Group {
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
                            
                            Button(action: onInfoTap) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                            }
                            .layoutPriority(2)
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