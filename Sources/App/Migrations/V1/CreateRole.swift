//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor
import Fluent

struct CreateRole: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Role.schema)
            .id()
            .field(Role.FieldKeys.name, .string, .required)
            .field(Role.FieldKeys.desc, .string)
            .field(Role.FieldKeys.createdAt, .datetime)
            .field(Role.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Role.schema).delete()
    }
}
