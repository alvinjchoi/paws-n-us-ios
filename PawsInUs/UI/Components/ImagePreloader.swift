//
//  ImagePreloader.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI

struct ImagePreloader {
    static func preloadImages(from urls: [String]) {
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            
            // Check if already cached
            if ImageCache.shared.image(for: url) != nil {
                continue
            }
            
            // Preload in background
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                ImageCache.shared.setImage(image, for: url)
            }.resume()
        }
    }
    
    static func preloadDogImages(_ dogs: [Dog]) {
        let urls = dogs.flatMap { $0.imageURLs }
        preloadImages(from: urls)
    }
}