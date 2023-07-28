//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//



import Vapor
import Fluent

struct CreateUserRole: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserRole.schema)
            .id()
            .field(UserRole.FieldKeys.userId, .uuid, .required)
            .field(UserRole.FieldKeys.roleId, .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(UserRole.schema).delete()
    }
}
