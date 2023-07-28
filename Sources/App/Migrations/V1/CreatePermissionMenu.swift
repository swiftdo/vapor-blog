//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor
import Fluent

struct CreatePermissionMenu: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PermissionMenu.schema)
            .id()
            .field(PermissionMenu.FieldKeys.permissionId, .uuid, .required)
            .field(PermissionMenu.FieldKeys.menuId, .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(PermissionMenu.schema).delete()
    }
}
