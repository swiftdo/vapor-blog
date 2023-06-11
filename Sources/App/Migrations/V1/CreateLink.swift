//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/11.
//


import Vapor
import Fluent

struct CreateLink: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Link.schema)
            .id()
            .field(Link.FieldKeys.title, .string)
            .field(Link.FieldKeys.status, .int8, .required)
            .field(Link.FieldKeys.href, .string)
            .field(Link.FieldKeys.weight, .int8, .required)
            .field(Link.FieldKeys.ownerId, .uuid, .required)
            .field(Link.FieldKeys.createdAt, .datetime)
            .field(Link.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Link.schema).delete()
    }
}
