//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/11.
//


import Vapor
import Fluent

struct CreateComment: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Comment.schema)
            .id()
            .field(Comment.FieldKeys.content, .string)
            .field(Comment.FieldKeys.status, .int, .required)
            .field(Comment.FieldKeys.website, .string)
            .field(Comment.FieldKeys.email, .string, .required)
            .field(Comment.FieldKeys.targetId, .uuid, .required)
            .field(Comment.FieldKeys.createdAt, .datetime)
            .field(Comment.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Comment.schema).delete()
    }
}
