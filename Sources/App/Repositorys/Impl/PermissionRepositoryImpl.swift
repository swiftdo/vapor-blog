//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Foundation
import Vapor
import Fluent

struct PermissionRepositoryImpl: PermissionRepository {
  var req: Request
  
  init(_ req: Request) {
    self.req = req
  }
  
  func add(param: InPermission, ownerId: User.IDValue) async throws -> Permission {
    let item = Permission(name: param.name, desc: param.desc, code: param.code)
    try await item.create(on: req.db)
    return item
  }
  
  func page(ownerId: User.IDValue?) async throws -> FluentKit.Page<Permission.Public> {
    return try await Permission.query(on: req.db)
        .sort(\.$createdAt, .descending)
        .paginate(for:req)
        .map({$0.asPublic()})
  }
  
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws {
    try await Permission.query(on: req.db)
      .filter(\.$id ~~ ids.ids)
      .delete(force: true)
  }
  
  func update(param: InUpdatePermission, ownerId: User.IDValue) async throws {
    try await Permission.query(on: req.db)
      .set(\.$name, to: param.name)
      .set(\.$desc, to: param.desc)
      .set(\.$code, to: param.code)
      .filter(\.$id == param.id)
      .update()
  }
  
  func all(ownerId: User.IDValue?) async throws -> [Permission.Public] {
    return try await Permission.query(on: req.db)
        .sort(\.$createdAt, .descending)
        .all()
        .map({$0.asPublic()})
  }
}
