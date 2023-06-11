//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/11.
//


import Vapor
import Fluent

struct CreatePostTag: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PostTag.schema)
            .id()
            .field(PostTag.FieldKeys.postId, .uuid, .required)
            .field(PostTag.FieldKeys.tagId, .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(PostTag.schema).delete()
    }
}

