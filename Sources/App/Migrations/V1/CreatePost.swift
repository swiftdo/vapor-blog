//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/11.
//

import Vapor
import Fluent

struct CreatePost: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Post.schema)
            .id()
            .field(Post.FieldKeys.title, .string)
            .field(Post.FieldKeys.status, .int8, .required)
            .field(Post.FieldKeys.desc, .string)
            .field(Post.FieldKeys.content, .string, .required)
            .field(Post.FieldKeys.ownerId, .uuid, .required)
            .field(Post.FieldKeys.categoryId, .uuid, .required)
            .field(Post.FieldKeys.createdAt, .datetime)
            .field(Post.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Post.schema).delete()
    }
}
