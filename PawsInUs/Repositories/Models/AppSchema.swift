//
//  AppSchema.swift
//  Pawsinus
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import Foundation
#if canImport(SwiftData)
import SwiftData
#endif

#if canImport(SwiftData)
@available(iOS 17.0, *)
typealias DBModel = SchemaV1

@available(iOS 17.0, *)
enum SchemaV1: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        // We need at least one model for SwiftData to work properly
        // This is a dummy model that won't be used
        [DummyModel.self]
    }
}

// Dummy model to satisfy SwiftData requirements
@available(iOS 17.0, *)
@Model
final class DummyModel {
    var id: String = UUID().uuidString
    
    init() {}
}

@available(iOS 17.0, *)
extension Schema {
    static var appSchema: Schema {
        Schema(versionedSchema: SchemaV1.self)
    }
}
#endif
