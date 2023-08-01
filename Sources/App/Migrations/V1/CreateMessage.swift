//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//

import Vapor
import Fluent

struct CreateMessage: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Message.schema)
            .id()
            .field(Message.FieldKeys.status, .int, .required)
            .field(Message.FieldKeys.senderId, .uuid, .required)
            .field(Message.FieldKeys.receiverId, .uuid, .required)
            .field(Message.FieldKeys.msgInfoId, .uuid, .required)
            .field(Message.FieldKeys.createdAt, .datetime)
            .field(Message.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Message.schema).delete()
    }
}
