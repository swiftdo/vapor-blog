//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/14.
//

import Fluent

struct CreateEmailCode: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(EmailCode.schema)
            .id()
            .field(EmailCode.FieldKeys.email, .string, .required)
            .field(EmailCode.FieldKeys.code, .string, .required)
            .field(EmailCode.FieldKeys.status, .int, .required)
            .field(EmailCode.FieldKeys.type, .string, .required)
            .field(EmailCode.FieldKeys.createdAt, .datetime)
            .field(EmailCode.FieldKeys.updatedAt, .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(EmailCode.schema).delete()
    }
}
