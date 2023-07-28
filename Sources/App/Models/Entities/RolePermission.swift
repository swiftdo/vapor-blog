//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Fluent
import Vapor

final class RolePermission: Model {
    static let schema = "blog_role_permision"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.permissionId)
    var permission: Permission

    @Parent(key: FieldKeys.roleId)
    var role: Role
    
    init() { }

  init(id: UUID? = nil, permissionId: Permission.IDValue, roleId:Role.IDValue)  {
      self.id = id
      self.$permission.id = permissionId
      self.$role.id = roleId
  }
}

extension RolePermission {
    struct FieldKeys {
        static var roleId: FieldKey { "role_id" }
        static var permissionId: FieldKey { "permission_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
