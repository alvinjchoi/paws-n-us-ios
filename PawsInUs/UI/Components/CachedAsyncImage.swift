//
//  CachedAsyncImage.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var retryCount = 0
    private let maxRetries = 3
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(for: url) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        // Debug print
        print("Loading image from URL: \(url)")
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Image load error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Retry if we haven't exceeded max retries
                    if self.retryCount < self.maxRetries {
                        self.retryCount += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.loadImage()
                        }
                    }
                }
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                print("Failed to create image from data for URL: \(url)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Cache the image
            ImageCache.shared.setImage(downloadedImage, for: url)
            
            DispatchQueue.main.async {
                self.image = downloadedImage
                self.isLoading = false
                self.retryCount = 0
            }
        }.resume()
    }
}

// Simple in-memory image cache
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Maximum 100 images
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        let cost = image.pngData()?.count ?? 0
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
    
    func removeImage(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }
    
    func removeAllImages() {
        cache.removeAllObjects()
    }
}