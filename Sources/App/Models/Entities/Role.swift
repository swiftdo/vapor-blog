//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Fluent
import Vapor

// 角色
final class Role: Model {
  static let schema = "blog_role"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: FieldKeys.name)
  var name: String
  
  @OptionalField(key: FieldKeys.desc)
  var desc: String?
  
  // 该角色的用户
  @Siblings(through: UserRole.self, from: \.$role, to: \.$user)
  var users: [User]

  // 该角色能够使用的权限
  @Siblings(through: RolePermission.self, from: \.$role, to: \.$permission)
  var permissions: [Permission]
  
  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?
  
  @Timestamp(key: FieldKeys.updatedAt, on: .update)
  var updatedAt: Date?

  init() {}
  
  init(id: UUID? = nil, name: String, desc: String? = nil) {
    self.id = id
    self.name = name
    self.desc = desc
  }
}

extension Role {
  struct FieldKeys {
    static var name: FieldKey { "name" }
    static var desc: FieldKey { "desc" }
    static var createdAt: FieldKey { "created_at" }
    static var updatedAt: FieldKey { "updated_at" }
  }
}



