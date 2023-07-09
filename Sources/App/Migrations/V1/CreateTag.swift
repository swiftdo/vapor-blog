//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/11.
//
import Vapor
import Fluent

struct CreateTag: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Tag.schema)
            .id()
            .field(Tag.FieldKeys.name, .string)
            .field(Tag.FieldKeys.status, .int, .required)
            .field(Tag.FieldKeys.ownerId, .uuid, .required)
            .field(Tag.FieldKeys.createdAt, .datetime)
            .field(Tag.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Tag.schema).delete()
    }
}
