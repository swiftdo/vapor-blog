//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//


import Vapor
import Fluent

struct CreatePermission: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Permission.schema)
            .id()
            .field(Permission.FieldKeys.name, .string, .required)
            .field(Permission.FieldKeys.code, .string, .required)
            .field(Permission.FieldKeys.desc, .string)
            .field(Permission.FieldKeys.createdAt, .datetime)
            .field(Permission.FieldKeys.updatedAt, .datetime)
            .unique(on: Permission.FieldKeys.code)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Permission.schema).delete()
    }
}
