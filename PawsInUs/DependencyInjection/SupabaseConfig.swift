import Foundation
import Supabase

struct SupabaseConfig {
    // Load configuration from Info.plist
    static let url: URL = {
        do {
            let urlString = try ConfigurationManager.string(for: ConfigurationKey.supabaseURL)
            guard let url = URL(string: urlString) else {
                fatalError("Invalid Supabase URL in configuration")
            }
            return url
        } catch {
            // Fallback for development - remove in production
            #if DEBUG
            return URL(string: "https://jxhtbzipglekixpogclo.supabase.co")!
            #else
            fatalError("Missing SUPABASE_URL in Info.plist")
            #endif
        }
    }()
    
    static let anonKey: String = {
        do {
            return try ConfigurationManager.string(for: ConfigurationKey.supabaseAnonKey)
        } catch {
            // Fallback for development - remove in production
            #if DEBUG
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4aHRiemlwZ2xla2l4cG9nY2xvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1OTUyMzMsImV4cCI6MjA2OTE3MTIzM30.a0heLND69cS5RWERvkOQ0s4g3rjfg7gxkSJzPlc9K7M"
            #else
            fatalError("Missing SUPABASE_ANON_KEY in Info.plist")
            #endif
        }
    }()
    
    // Create a singleton instance to avoid recreation
    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey
    )
}