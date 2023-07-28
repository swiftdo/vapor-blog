//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//
import Vapor
import Fluent

/// 权限
final class Permission: Model {
  static let schema = "blog_permission"
  
  @ID(key: .id)
  var id: UUID?
  
  // 权限名字
  @Field(key: FieldKeys.name)
  var name: String
  
  // 权限代码，需要唯一，后面校验权限的时候需要用到
  @Field(key: FieldKeys.code)
  var code: String
  
  @OptionalField(key: FieldKeys.desc)
  var desc: String?
  
  // 权限可以对应多个角色
  @Siblings(through: RolePermission.self, from: \.$permission, to: \.$role)
  var roles: [Role]
  
  @Siblings(through: PermissionMenu.self, from: \.$permission, to: \.$menu)
  var menus: [Menu]
  
  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?
  
  @Timestamp(key: FieldKeys.updatedAt, on: .update)
  var updatedAt: Date?

  init() {}
  
  init(id: UUID? = nil, name: String, desc: String? = nil, code: String) {
    self.id = id
    self.name = name
    self.desc = desc
    self.code = code
  }
}

extension Permission {
  struct FieldKeys {
    static var name: FieldKey { "name" }
    static var desc: FieldKey { "desc" }
    static var code: FieldKey { "code" }
    static var createdAt: FieldKey { "created_at" }
    static var updatedAt: FieldKey { "updated_at" }
  }
}
