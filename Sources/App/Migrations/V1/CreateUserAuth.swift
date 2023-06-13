//
//  File.swift
//
//
//  Created by laijihua on 2022/8/30.
//

import Fluent
struct CreateUserAuth: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserAuth.schema)
            .id()
            .field(UserAuth.FieldKeys.userId, .uuid, .references(User.schema, .id))
            .field(UserAuth.FieldKeys.authType, .string, .required)
            .field(UserAuth.FieldKeys.identifier, .string, .required)
            .field(UserAuth.FieldKeys.credential, .string, .required)
            .field(UserAuth.FieldKeys.createdAt, .datetime)
            .field(UserAuth.FieldKeys.updatedAt, .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(UserAuth.schema).delete()
    }
}
