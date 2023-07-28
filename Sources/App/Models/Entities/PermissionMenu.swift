//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//


import Fluent
import Vapor

final class PermissionMenu: Model {
    static let schema = "blog_permision_menu"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.permissionId)
    var permission: Permission

    @Parent(key: FieldKeys.menuId)
    var menu: Menu
    
    init() { }

  init(id: UUID? = nil, permissionId: Permission.IDValue, menuId:Menu.IDValue)  {
      self.id = id
      self.$permission.id = permissionId
      self.$menu.id = menuId
  }
}

extension PermissionMenu {
    struct FieldKeys {
        static var menuId: FieldKey { "menu_id" }
        static var permissionId: FieldKey { "permission_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
