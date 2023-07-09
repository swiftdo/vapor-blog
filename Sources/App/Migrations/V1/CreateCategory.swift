//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/11.
//

import Vapor
import Fluent

struct CreateCategory: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(Category.schema)
            .id()
            .field(Category.FieldKeys.name, .string)
            .field(Category.FieldKeys.status, .int, .required)
            .field(Category.FieldKeys.isNav, .bool, .required)
            .field(Category.FieldKeys.ownerId, .uuid, .required)
            .field(Category.FieldKeys.createdAt, .datetime)
            .field(Category.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Category.schema).delete()
    }
}
