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
            .field(Comment.FieldKeys.status, .int, .required)
            .field(Comment.FieldKeys.content, .string, .required)
            .field(Comment.FieldKeys.topicId, .uuid, .required)
            .field(Comment.FieldKeys.topicType, .int, .required)
            .field(Comment.FieldKeys.fromUid, .uuid, .required)
            .field(Comment.FieldKeys.createdAt, .datetime)
            .field(Comment.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Comment.schema).delete()
    }
}
