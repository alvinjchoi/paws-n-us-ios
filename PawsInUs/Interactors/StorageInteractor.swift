import Foundation
import UIKit

protocol StorageInteractor {
    func uploadDogImage(dogID: String, image: UIImage) async throws -> String
    func uploadProfileImage(adopterID: String, image: UIImage) async throws -> String
    func deleteDogImage(url: String) async throws
    func deleteProfileImage(url: String) async throws
}

extension DIContainer.Interactors {
    var storageInteractor: StorageInteractor {
        RealStorageInteractor(storageRepository: repositories.storageRepository)
    }
}

struct RealStorageInteractor: StorageInteractor {
    let storageRepository: StorageRepository
    
    func uploadDogImage(dogID: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImageData
        }
        
        let fileName = SupabaseStorageRepository.generateFileName(prefix: "dog_\(dogID)")
        let path = "dogs/\(dogID)/\(fileName)"
        
        return try await storageRepository.uploadImage(
            bucket: SupabaseStorageRepository.buckets.dogImages,
            path: path,
            data: imageData
        )
    }
    
    func uploadProfileImage(adopterID: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImageData
        }
        
        let fileName = SupabaseStorageRepository.generateFileName(prefix: "profile")
        let path = "adopters/\(adopterID)/\(fileName)"
        
        return try await storageRepository.uploadImage(
            bucket: SupabaseStorageRepository.buckets.profileImages,
            path: path,
            data: imageData
        )
    }
    
    func deleteDogImage(url: String) async throws {
        let path = extractPath(from: url, bucket: SupabaseStorageRepository.buckets.dogImages)
        try await storageRepository.deleteImage(
            bucket: SupabaseStorageRepository.buckets.dogImages,
            path: path
        )
    }
    
    func deleteProfileImage(url: String) async throws {
        let path = extractPath(from: url, bucket: SupabaseStorageRepository.buckets.profileImages)
        try await storageRepository.deleteImage(
            bucket: SupabaseStorageRepository.buckets.profileImages,
            path: path
        )
    }
    
    private func extractPath(from url: String, bucket: String) -> String {
        // Extract the path from the URL
        // Example: https://xxx.supabase.co/storage/v1/object/public/dog-images/dogs/123/image.jpg
        // Returns: dogs/123/image.jpg
        if let range = url.range(of: "/\(bucket)/") {
            return String(url[range.upperBound...])
        }
        return ""
    }
}

enum StorageError: LocalizedError {
    case invalidImageData
    case uploadFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Failed to convert image to data"
        case .uploadFailed:
            return "Failed to upload image"
        }
    }
}