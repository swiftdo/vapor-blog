//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//

import Vapor
import Fluent

struct CreateMessageInfo: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(MessageInfo.schema)
            .id()
            .field(MessageInfo.FieldKeys.targetId, .uuid)
            .field(MessageInfo.FieldKeys.title, .string, .required)
            .field(MessageInfo.FieldKeys.content, .string, .required)
            .field(MessageInfo.FieldKeys.msgType, .int, .required)
            .field(MessageInfo.FieldKeys.createdAt, .datetime)
            .field(MessageInfo.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(MessageInfo.schema).delete()
    }
}
