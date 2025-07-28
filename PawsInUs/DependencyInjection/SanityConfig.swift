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
            print("Warning: Using hardcoded Sanity project ID. Set SANITY_PROJECT_ID in Info.plist")
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
            print("Warning: Using hardcoded Sanity dataset. Set SANITY_DATASET in Info.plist")
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
        
        print("Sanity Query: \(query)")
        print("Sanity URL: \(url)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Sanity network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("Sanity: No data received")
                completion(.failure(SanityError.noData))
                return
            }
            
            print("Sanity response data length: \(data.count)")
            
            do {
                let sanityResponse = try JSONDecoder().decode(SanityResponse<T>.self, from: data)
                print("Sanity: Successfully decoded response")
                completion(.success(sanityResponse.result))
            } catch {
                print("Sanity decode error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON: \(jsonString)")
                }
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
        let query = """
        *[_type == "article" && published == true] | order(publishedDate desc) {
          _id,
          title,
          subtitle,
          category,
          "imageUrl": coalesce(imageURL, featuredImage.asset->url),
          author,
          publishedDate,
          readTime,
          location,
          featured,
          "slug": slug.current
        }
        """
        
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
        let query = """
        *[_type == "article" && published == true && featured == true] | order(publishedDate desc) {
          _id,
          title,
          subtitle,
          category,
          "imageUrl": coalesce(imageURL, featuredImage.asset->url),
          author,
          publishedDate,
          readTime,
          location,
          featured,
          "slug": slug.current
        }
        """
        
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
        let query = """
        *[_type == "article" && published == true && category == "\(category)"] | order(publishedDate desc) {
          _id,
          title,
          subtitle,
          category,
          "imageUrl": coalesce(imageURL, featuredImage.asset->url),
          author,
          publishedDate,
          readTime,
          location,
          featured,
          "slug": slug.current
        }
        """
        
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
        let query = """
        *[_type == "article" && _id == "\(id)"][0] {
          _id,
          title,
          subtitle,
          category,
          "imageUrl": coalesce(imageURL, featuredImage.asset->url),
          content,
          author,
          publishedDate,
          readTime,
          location,
          "slug": slug.current
        }
        """
        
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