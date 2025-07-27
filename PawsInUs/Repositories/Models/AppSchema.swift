//
//  AppSchema.swift
//  Pawsinus
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import SwiftData

typealias DBModel = SchemaV1

enum SchemaV1: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [] // Empty - we're using Supabase for all data storage
    }
}

extension Schema {
    static var appSchema: Schema {
        Schema(versionedSchema: SchemaV1.self)
    }
}
