//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//

import Vapor
import Fluent

struct CreateReply: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Reply.schema)
            .id()
            .field(Reply.FieldKeys.status, .int, .required)
            .field(Reply.FieldKeys.content, .string, .required)
            .field(Reply.FieldKeys.targetId, .uuid, .required)
            .field(Reply.FieldKeys.targetType, .int, .required)
            .field(Reply.FieldKeys.fromUid, .uuid, .required)
            .field(Reply.FieldKeys.toUid, .uuid)
            .field(Reply.FieldKeys.commentId, .uuid, .required)
            .field(Reply.FieldKeys.createdAt, .datetime)
            .field(Reply.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Reply.schema).delete()
    }
}

