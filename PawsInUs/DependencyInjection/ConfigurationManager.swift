//
//  ConfigurationManager.swift
//  PawsInUs
//
//  Manages configuration values from Info.plist
//

import Foundation

enum ConfigurationError: Error {
    case missingKey, invalidValue
}

struct ConfigurationManager {
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw ConfigurationError.missingKey
        }
        
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw ConfigurationError.invalidValue
        }
    }
    
    static func string(for key: String) throws -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            throw ConfigurationError.missingKey
        }
        return value
    }
    
    static func optionalString(for key: String) -> String? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
}

// Configuration Keys
enum ConfigurationKey {
    static let supabaseURL = "SUPABASE_URL"
    static let supabaseAnonKey = "SUPABASE_ANON_KEY"
    static let sanityProjectID = "SANITY_PROJECT_ID"
    static let sanityDataset = "SANITY_DATASET"
}