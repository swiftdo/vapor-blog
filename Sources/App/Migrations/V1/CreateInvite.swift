//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/23.
//

import Fluent

struct CreateInvite: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Invite.schema)
            .id()
            .field(Invite.FieldKeys.code, .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Invite.schema).delete()
    }
}
