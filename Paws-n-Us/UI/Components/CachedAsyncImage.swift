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
    @State private var loadFailed = false
    private let maxRetries = 3
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else if loadFailed {
                // Show error state
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Failed to load")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
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
        
        // Set a timeout to prevent infinite loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isLoading && self.image == nil {
                self.isLoading = false
                self.loadFailed = true
            }
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // CachedAsyncImage: Error loading
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Retry if we haven't exceeded max retries
                    if self.retryCount < self.maxRetries {
                        self.retryCount += 1
                        // CachedAsyncImage: Retrying
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.loadImage()
                        }
                    } else {
                        // Mark as failed after max retries
                        // CachedAsyncImage: Failed after max retries
                        self.loadFailed = true
                    }
                }
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.loadFailed = true
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

// Thread-safe in-memory image cache
final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()
    private let lock = NSLock()
    
    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Maximum 100 images
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }
    
    func image(for url: URL) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache.object(forKey: url as NSURL)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        let cost = image.pngData()?.count ?? 0
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
    
    func removeImage(for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        cache.removeObject(forKey: url as NSURL)
    }
    
    func removeAllImages() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAllObjects()
    }
}