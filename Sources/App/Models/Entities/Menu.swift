//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//


import Fluent
import Vapor

/// 菜单: 角色和权限用于控制用户的访问权限，而菜单是根据用户的权限动态生成的
final class Menu: Model {
  
  static let schema = "blog_menu"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: FieldKeys.name)
  var name: String
  
  @Field(key: FieldKeys.url)
  var url: String
  
  @Field(key: FieldKeys.status)
  var status: Int // 正常|删除
  
  @Field(key: FieldKeys.weight)
  var weight: Int
  
  @OptionalParent(key: FieldKeys.parentId)  // 指向自身的外键
  var parent: Menu?
  
  @Siblings(through: PermissionMenu.self, from: \.$menu, to: \.$permission)
  var permissions: [Permission]
  
  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?
  
  @Timestamp(key: FieldKeys.updatedAt, on: .update)
  var updatedAt: Date?
  
  init() { }
  
  init(id: UUID? = nil, name: String, url: String, status: Int = 1, weight: Int = 1, parentId: Menu.IDValue? = nil) {
    self.id = id
    self.name = name
    self.url = url
    self.status = status
    self.weight = weight
    self.$parent.id = parentId
  }
}

extension Menu {
  struct FieldKeys {
    static var status: FieldKey { "status" }
    static var parentId: FieldKey { "parent_id" }
    static var name: FieldKey { "name" }
    static var url: FieldKey { "url" }
    static var weight: FieldKey { "weight" }
    static var createdAt: FieldKey { "created_at" }
    static var updatedAt: FieldKey { "updated_at" }
  }
}
