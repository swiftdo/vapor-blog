//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor
import Fluent

struct CreateMenu: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Menu.schema)
            .id()
            .field(Menu.FieldKeys.name, .string, .required)
            .field(Menu.FieldKeys.status, .int, .required)
            .field(Menu.FieldKeys.url, .string, .required)
            .field(Menu.FieldKeys.weight, .int, .required)
            .field(Menu.FieldKeys.parentId, .uuid)
            .field(Menu.FieldKeys.createdAt, .datetime)
            .field(Menu.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Menu.schema).delete()
    }
}

