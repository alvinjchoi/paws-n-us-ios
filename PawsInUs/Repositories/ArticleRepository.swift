//
//  ArticleRepository.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import Foundation
import Combine
import SwiftUI

protocol ArticleRepository {
    func getAllArticles() -> AnyPublisher<[Article], Error>
    func getFeaturedArticles() -> AnyPublisher<[Article], Error>
    func getArticles(by category: ArticleCategory) -> AnyPublisher<[Article], Error>
    func getArticle(by id: String) -> AnyPublisher<Article?, Error>
}

final class SanityArticleRepository: ArticleRepository, ObservableObject {
    
    func getAllArticles() -> AnyPublisher<[Article], Error> {
        // For now, return sample data to avoid concurrency issues
        Just(Article.sampleArticles)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getFeaturedArticles() -> AnyPublisher<[Article], Error> {
        Just(Article.sampleArticles.filter { $0.featured })
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getArticles(by category: ArticleCategory) -> AnyPublisher<[Article], Error> {
        Just(Article.sampleArticles.filter { $0.categoryEnum == category })
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getArticle(by id: String) -> AnyPublisher<Article?, Error> {
        Just(Article.sampleArticles.first { $0.id == id })
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}