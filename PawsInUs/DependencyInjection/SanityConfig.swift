//
//  SanityConfig.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import Foundation

struct SanityConfig {
    static let projectId: String = {
        do {
            return try ConfigurationManager.string(for: ConfigurationKey.sanityProjectID)
        } catch {
            // Fallback for development - remove in production
            #if DEBUG
            return "p4k25a1o"
            #else
            fatalError("Missing SANITY_PROJECT_ID in Info.plist")
            #endif
        }
    }()
    
    static let dataset: String = {
        do {
            return try ConfigurationManager.string(for: ConfigurationKey.sanityDataset)
        } catch {
            // Fallback for development - remove in production
            #if DEBUG
            return "production"
            #else
            fatalError("Missing SANITY_DATASET in Info.plist")
            #endif
        }
    }()
    
    static let apiVersion = "2024-01-01"
    static let baseURL = "https://\(projectId).api.sanity.io/v\(apiVersion)/data/query/\(dataset)"
}

struct SanityResponse<T: Codable>: Codable {
    let result: T
}

final class SanityClient: @unchecked Sendable {
    static let shared = SanityClient()
    
    private init() {}
    
    private func buildURL(query: String) -> URL? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(SanityConfig.baseURL)?query=\(encodedQuery)"
        return URL(string: urlString)
    }
    
    // MARK: - Generic Query Method
    
    private func executeQuery<T: Codable>(
        query: String,
        responseType: T.Type,
        completion: @escaping @Sendable (Result<T, Error>) -> Void
    ) {
        guard let url = buildURL(query: query) else {
            completion(.failure(SanityError.invalidURL))
            return
        }
        
        
        // Configure URLSession to handle external images
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        let session = URLSession(configuration: config)
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(SanityError.noData))
                return
            }
            
            
            do {
                let sanityResponse = try JSONDecoder().decode(SanityResponse<T>.self, from: data)
                completion(.success(sanityResponse.result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Article Queries
    
    func fetchArticles() async throws -> [Article] {
        try await withCheckedThrowingContinuation { continuation in
            fetchArticlesWithCompletion { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func fetchArticlesWithCompletion(completion: @escaping @Sendable (Result<[Article], Error>) -> Void) {
        let query = "*[_type==\"article\"] | order(publishedDate desc) { _id, title, subtitle, category, \"imageUrl\": coalesce(imageURL, featuredImage.asset->url), author, publishedDate, readTime, location, featured, \"slug\": slug.current, content }"
        
        executeQuery(query: query, responseType: [Article].self, completion: completion)
    }
    
    func fetchFeaturedArticles() async throws -> [Article] {
        try await withCheckedThrowingContinuation { continuation in
            fetchFeaturedArticlesWithCompletion { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func fetchFeaturedArticlesWithCompletion(completion: @escaping @Sendable (Result<[Article], Error>) -> Void) {
        let query = "*[_type==\"article\" && featured==true] | order(publishedDate desc) { _id, title, subtitle, category, \"imageUrl\": coalesce(imageURL, featuredImage.asset->url), author, publishedDate, readTime, location, featured, \"slug\": slug.current, content }"
        
        executeQuery(query: query, responseType: [Article].self, completion: completion)
    }
    
    func fetchArticles(by category: String) async throws -> [Article] {
        try await withCheckedThrowingContinuation { continuation in
            fetchArticlesWithCompletion(by: category) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func fetchArticlesWithCompletion(by category: String, completion: @escaping @Sendable (Result<[Article], Error>) -> Void) {
        let query = "*[_type==\"article\" && category==\"\(category)\"] | order(publishedDate desc) { _id, title, subtitle, category, \"imageUrl\": coalesce(imageURL, featuredImage.asset->url), author, publishedDate, readTime, location, featured, \"slug\": slug.current, content }"
        
        executeQuery(query: query, responseType: [Article].self, completion: completion)
    }
    
    func fetchArticle(by id: String) async throws -> Article? {
        try await withCheckedThrowingContinuation { continuation in
            fetchArticleWithCompletion(by: id) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func fetchArticleWithCompletion(by id: String, completion: @escaping @Sendable (Result<Article?, Error>) -> Void) {
        let query = "*[_type == \"article\" && _id == \"\(id)\"][0] { _id, title, subtitle, category, \"imageUrl\": coalesce(imageURL, featuredImage.asset->url), content, author, publishedDate, readTime, location, \"slug\": slug.current }"
        
        executeQuery(query: query, responseType: Article?.self, completion: completion)
    }
}

// MARK: - Errors

enum SanityError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Sanity API URL"
        case .noData:
            return "No data received from Sanity API"
        case .decodingError:
            return "Failed to decode Sanity response"
        }
    }
}