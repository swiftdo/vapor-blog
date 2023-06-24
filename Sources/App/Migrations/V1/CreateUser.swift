//
//  File.swift
//
//
//  Created by laijihua on 2023/6/11.
//

import Fluent
import Vapor

struct CreateUser: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(User.schema)
      .id()
      .field(User.FieldKeys.name, .string, .required)
      .field(User.FieldKeys.email, .string, .required)
      .field(User.FieldKeys.isEmailVerified, .bool, .required, .custom("DEFAULT FALSE"))
      .field(User.FieldKeys.status, .int)
      .field(User.FieldKeys.isAdmin, .bool)
      .field(User.FieldKeys.inviteCode, .string)
      .field(User.FieldKeys.superiorId, .uuid)
      .field(User.FieldKeys.createdAt, .datetime)
      .field(User.FieldKeys.updatedAt, .datetime)
      .unique(on: User.FieldKeys.email)
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema(User.schema).delete()
  }
}
