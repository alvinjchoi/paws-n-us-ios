import Foundation
import Supabase

struct SupabaseConfig {
    static let url = URL(string: "YOUR_SUPABASE_PROJECT_URL")!
    static let anonKey = "YOUR_SUPABASE_ANON_KEY"
    
    static var client: SupabaseClient {
        SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }
}