//
//  DebugImageView.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI

struct DebugImageView: View {
    let url: String
    let index: Int
    
    var body: some View {
        VStack {
            Text("Image \(index)")
                .font(.caption)
            
            if let imageUrl = URL(string: url) {
                CachedAsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
                .frame(height: 160)
                .clipped()
            }
            
            Text(url)
                .font(.system(size: 8))
                .lineLimit(2)
                .padding(.horizontal, 4)
        }
        .onAppear {
            print("Debug: Loading image \(index) from URL: \(url)")
        }
    }
}