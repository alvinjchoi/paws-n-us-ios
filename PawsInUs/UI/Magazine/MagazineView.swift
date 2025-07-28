//
//  MagazineView.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI

struct MagazineView: View {
    @Environment(\.injected) private var diContainer
    @State private var articles = Article.sampleArticles
    
    var featuredArticles: [Article] {
        articles.filter { $0.category == .featured }
    }
    
    var guideArticles: [Article] {
        articles.filter { $0.category == .guides }
    }
    
    var placeArticles: [Article] {
        articles.filter { $0.category == .places }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                headerView
                
                NavigationView {
                    ScrollView {
                        VStack(spacing: 0) {
                    // Hero Featured Article
                    if let heroArticle = featuredArticles.first {
                        HeroArticleView(article: heroArticle)
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
                                        .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
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
            .navigationBarHidden(true)
            .background(Color(.systemGray6))
        }
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
}

// MARK: - Hero Article View
struct HeroArticleView: View {
    let article: Article
    
    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: article)) {
            VStack(spacing: 0) {
                // Large featured image
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1.0, contentMode: .fit)
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
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Text(article.subtitle)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                        .padding()
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
        VStack(alignment: .leading, spacing: 12) {
            Text(article.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
            
            Text(article.subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                        Text(article.category.displayName)
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
                        
                        Text(article.publishedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Content
                    Text(article.content)
                        .font(.body)
                        .lineSpacing(8)
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