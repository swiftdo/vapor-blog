//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//
import Fluent
import Vapor

final class UserRole: Model {
    static let schema = "blog_user_role"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.userId)
    var user: User

    @Parent(key: FieldKeys.roleId)
    var role: Role
    
    init() { }

  init(id: UUID? = nil, userId: User.IDValue, roleId:Role.IDValue)  {
      self.id = id
      self.$user.id = userId
      self.$role.id = roleId
  }
}

extension UserRole {
    struct FieldKeys {
        static var roleId: FieldKey { "role_id" }
        static var userId: FieldKey { "user_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}


