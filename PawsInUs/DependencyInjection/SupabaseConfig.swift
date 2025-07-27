import Foundation
import Supabase

struct SupabaseConfig {
    static let url = URL(string: "https://jxhtbzipglekixpogclo.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4aHRiemlwZ2xla2l4cG9nY2xvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1OTUyMzMsImV4cCI6MjA2OTE3MTIzM30.a0heLND69cS5RWERvkOQ0s4g3rjfg7gxkSJzPlc9K7M"
    
    // Create a singleton instance to avoid recreation
    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey
    )
}