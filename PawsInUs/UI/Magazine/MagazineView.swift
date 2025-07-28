//
//  MagazineView.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI
import Combine

struct MagazineView: View {
    @Environment(\.injected) private var diContainer
    @State private var articles: [Article] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    
    var featuredArticles: [Article] {
        articles.filter { $0.featured }
    }
    
    var guideArticles: [Article] {
        articles.filter { $0.categoryEnum == .guides }
    }
    
    var placeArticles: [Article] {
        articles.filter { $0.categoryEnum == .places }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                headerView
                
                NavigationView {
                    Group {
                        if isLoading {
                            ProgressView("Loading articles...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let errorMessage = errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.orange)
                                Text(errorMessage)
                                    .multilineTextAlignment(.center)
                                Button("다시 시도") {
                                    loadArticles()
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 0) {
                    // Hero Featured Article
                    if let heroArticle = featuredArticles.first {
                        HeroArticleView(article: heroArticle)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Secondary Featured Articles
                    if featuredArticles.count > 1 {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("The Rundown")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .textCase(.uppercase)
                                .padding(.horizontal)
                            
                            ForEach(featuredArticles.dropFirst().prefix(2)) { article in
                                NavigationLink(destination: ArticleDetailView(article: article)) {
                                    SecondaryFeaturedCard(article: article)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 32)
                    }
                    
                    // Guides Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Guides")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                GuideCard(
                                    title: "새로운 반려견 맞이하기",
                                    subtitle: "입양 후 첫 주를 위한 완벽 가이드",
                                    imageName: "heart.circle.fill",
                                    color: .pink
                                )
                                
                                GuideCard(
                                    title: "서울 애견 산책로",
                                    subtitle: "계절별 추천 산책 코스 모음",
                                    imageName: "map.fill",
                                    color: .green
                                )
                                
                                GuideCard(
                                    title: "건강 검진 체크리스트",
                                    subtitle: "연령별 필수 검진 항목 정리",
                                    imageName: "stethoscope",
                                    color: .blue
                                )
                            }
                            .padding(.horizontal)
                            .padding(.trailing, 20)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    // Places Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.orange)
                            Text("Hot Places")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(placeArticles.prefix(5)) { article in
                                NavigationLink(destination: ArticleDetailView(article: article)) {
                                    PlaceListItem(article: article)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if article.id != placeArticles.prefix(5).last?.id {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                                }
                        }
                    }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGray6))
            .clipped()
        }
            }
        }
        .onAppear {
            if articles.isEmpty {
                loadArticles()
            }
            // Debug: Print articles and their image URLs
            print("📰 Magazine loaded \(articles.count) articles:")
            for article in articles.prefix(3) {
                print("  - '\(article.title)': imageUrl = \(article.imageUrl ?? "nil")")
            }
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            // Logo section
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
    
    private func loadArticles() {
        isLoading = true
        errorMessage = nil
        
        print("📰 Starting to load articles from Sanity...")
        
        diContainer.interactors.repositories.articleRepository.getAllArticles()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        print("📰 Failed to load articles from Sanity: \(error.localizedDescription)")
                        errorMessage = "Failed to load articles: \(error.localizedDescription)"
                        // Fallback to sample data
                        print("📰 Falling back to sample data")
                        articles = Article.sampleArticles
                    } else {
                        print("📰 Successfully completed article loading")
                    }
                },
                receiveValue: { fetchedArticles in
                    print("📰 Received \(fetchedArticles.count) articles from Sanity")
                    if fetchedArticles.isEmpty {
                        print("📰 No articles received, falling back to sample data")
                        articles = Article.sampleArticles
                    } else {
                        print("📰 Using \(fetchedArticles.count) articles from Sanity")
                        for article in fetchedArticles.prefix(3) {
                            print("📰   - '\(article.title)': \(article.imageUrl ?? "nil")")
                        }
                        articles = fetchedArticles
                    }
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Hero Article View
struct HeroArticleView: View {
    let article: Article
    
    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: article)) {
            VStack(spacing: 0) {
                // Large featured image
                Group {
                    if let imageUrl = article.imageUrl, 
                       let url = URL(string: imageUrl),
                       !imageUrl.contains("example.com") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(let error):
                                Rectangle()
                                    .fill(Color.red.opacity(0.2))
                                    .overlay(
                                        VStack(spacing: 4) {
                                            Image(systemName: "exclamationmark.triangle")
                                                .font(.title2)
                                                .foregroundColor(.red)
                                            Text("Load Failed")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                            Text("\(error.localizedDescription)")
                                                .font(.caption2)
                                                .foregroundColor(.red)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .padding(8)
                                    )
                            case .empty:
                                Rectangle()
                                    .fill(Color.blue.opacity(0.3))
                                    .overlay(
                                        VStack {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            Text("Loading...")
                                                .foregroundColor(.white)
                                                .font(.caption)
                                        }
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                        }
                        .onAppear {
                            print("📸 Loading real image for article '\(article.title)': \(imageUrl)")
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("No image URL")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                            .onAppear {
                                if let imageUrl = article.imageUrl {
                                    print("📸 Placeholder URL filtered out for article '\(article.title)': \(imageUrl)")
                                } else {
                                    print("📸 No image URL for article: \(article.title)")
                                }
                            }
                    }
                }
                .frame(height: 300)
                .clipped()
                .overlay(
                    VStack {
                        Spacer()
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 200)
                    }
                )
                    .overlay(
                        VStack(alignment: .leading, spacing: 8) {
                            Spacer()
                            Text("One Great Guide")
                                .font(.caption)
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                            
                            Text(article.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                            
                            Text(article.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        , alignment: .bottomLeading
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Secondary Featured Card
struct SecondaryFeaturedCard: View {
    let article: Article
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail image - fixed size
            Group {
                if let imageUrl = article.imageUrl, 
                   let url = URL(string: imageUrl),
                   !imageUrl.contains("example.com") {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            )
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                Text("No URL")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        )
                }
            }
            .frame(width: 90, height: 70)
            .clipped()
            .cornerRadius(8)
            
            // Article content
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text(article.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Guide Card
struct GuideCard: View {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(color.opacity(0.15))
                .frame(width: 280, height: 200)
                .overlay(
                    Image(systemName: imageName)
                        .font(.system(size: 60))
                        .foregroundColor(color)
                )
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 280)
    }
}

// MARK: - Place List Item
struct PlaceListItem: View {
    let article: Article
    
    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .overlay(
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(article.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    if let location = article.location {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption)
                            Text(location)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(article.readTime)분")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "heart")
                .font(.title3)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header image
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        Text("Article Image")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 16) {
                    // Category and location
                    HStack {
                        Text(article.categoryEnum.displayName)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .textCase(.uppercase)
                        
                        if let location = article.location {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(article.readTime)분 읽기")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Title
                    Text(article.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Subtitle
                    Text(article.subtitle)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    // Author and date
                    HStack {
                        Text("by \(article.author)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(article.parsedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Content
                    if let contentBlocks = article.content {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(contentBlocks.indices, id: \.self) { index in
                                PortableTextView(block: contentBlocks[index])
                            }
                        }
                    } else {
                        Text("No content available")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Share functionality
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}