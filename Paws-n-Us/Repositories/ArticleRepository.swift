//
//  ArticleRepository.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import Foundation
@preconcurrency import Combine
import SwiftUI

protocol ArticleRepository {
    func getAllArticles() -> AnyPublisher<[Article], Error>
    func getFeaturedArticles() -> AnyPublisher<[Article], Error>
    func getArticles(by category: ArticleCategory) -> AnyPublisher<[Article], Error>
    func getArticle(by id: String) -> AnyPublisher<Article?, Error>
}

final class SanityArticleRepository: ArticleRepository, ObservableObject {
    
    func getAllArticles() -> AnyPublisher<[Article], Error> {
        let subject = PassthroughSubject<[Article], Error>()
        
        SanityClient.shared.fetchArticlesWithCompletion { result in
            switch result {
            case .success(let articles):
                subject.send(articles)
                subject.send(completion: .finished)
            case .failure(let error):
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getFeaturedArticles() -> AnyPublisher<[Article], Error> {
        let subject = PassthroughSubject<[Article], Error>()
        
        SanityClient.shared.fetchFeaturedArticlesWithCompletion { result in
            switch result {
            case .success(let articles):
                subject.send(articles)
                subject.send(completion: .finished)
            case .failure(let error):
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getArticles(by category: ArticleCategory) -> AnyPublisher<[Article], Error> {
        let subject = PassthroughSubject<[Article], Error>()
        
        SanityClient.shared.fetchArticlesWithCompletion(by: category.rawValue) { result in
            switch result {
            case .success(let articles):
                subject.send(articles)
                subject.send(completion: .finished)
            case .failure(let error):
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getArticle(by id: String) -> AnyPublisher<Article?, Error> {
        let subject = PassthroughSubject<Article?, Error>()
        
        SanityClient.shared.fetchArticleWithCompletion(by: id) { result in
            switch result {
            case .success(let article):
                subject.send(article)
                subject.send(completion: .finished)
            case .failure(let error):
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
}