//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor
import Fluent

struct CreateRolePermission: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(RolePermission.schema)
            .id()
            .field(RolePermission.FieldKeys.permissionId, .uuid, .required)
            .field(RolePermission.FieldKeys.roleId, .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(RolePermission.schema).delete()
    }
}
