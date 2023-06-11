//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/11.
//


import Vapor
import Fluent

struct CreateSideBar: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(SideBar.schema)
            .id()
            .field(SideBar.FieldKeys.title, .string)
            .field(SideBar.FieldKeys.status, .int8, .required)
            .field(SideBar.FieldKeys.displayType, .int8)
            .field(SideBar.FieldKeys.content, .string, .required)
            .field(SideBar.FieldKeys.ownerId, .uuid, .required)
            .field(SideBar.FieldKeys.createdAt, .datetime)
            .field(SideBar.FieldKeys.updatedAt, .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(SideBar.schema).delete()
    }
}

