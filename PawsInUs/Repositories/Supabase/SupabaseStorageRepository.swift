import Foundation
import Supabase

protocol StorageRepository {
    func uploadImage(bucket: String, path: String, data: Data) async throws -> String
    func getPublicURL(bucket: String, path: String) -> String
    func deleteImage(bucket: String, path: String) async throws
    func listImages(bucket: String, folder: String) async throws -> [String]
}

struct SupabaseStorageRepository: StorageRepository {
    let client: SupabaseClient
    
    func uploadImage(bucket: String, path: String, data: Data) async throws -> String {
        try await client.storage
            .from(bucket)
            .upload(
                path,
                data: data,
                options: FileOptions(
                    cacheControl: "3600",
                    upsert: true
                )
            )
        
        return getPublicURL(bucket: bucket, path: path)
    }
    
    func getPublicURL(bucket: String, path: String) -> String {
        do {
            return try client.storage
                .from(bucket)
                .getPublicURL(path: path)
                .absoluteString
        } catch {
            // If we can't generate the public URL, return a fallback
            return ""
        }
    }
    
    func deleteImage(bucket: String, path: String) async throws {
        try await client.storage
            .from(bucket)
            .remove(paths: [path])
    }
    
    func listImages(bucket: String, folder: String) async throws -> [String] {
        let files = try await client.storage
            .from(bucket)
            .list(path: folder)
        
        return files.map { file in
            getPublicURL(bucket: bucket, path: "\(folder)/\(file.name)")
        }
    }
}

extension SupabaseStorageRepository {
    static let buckets = StorageBuckets()
    
    struct StorageBuckets {
        let dogImages = "dog-images"
        let profileImages = "profile-images"
    }
    
    static func generateFileName(prefix: String, extension ext: String = "jpg") -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 1000...9999)
        return "\(prefix)_\(timestamp)_\(random).\(ext)"
    }
}