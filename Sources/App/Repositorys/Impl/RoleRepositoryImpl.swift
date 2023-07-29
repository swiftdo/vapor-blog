//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Foundation
import Vapor
import Fluent

struct RoleRepositoryImpl: RoleRepository {
  
  var req: Request
  
  init(_ req: Request) {
    self.req = req
  }
  
  func add(param: InRole, ownerId: User.IDValue) async throws -> Role {
    let item = Role(name: param.name)
    try await item.create(on: req.db)
    return item
  }

  func page(ownerId: User.IDValue?) async throws -> Page<Role.Public> {
    return try await Role.query(on: req.db)
        .sort(\.$createdAt, .descending)
        .paginate(for:req)
        .map({$0.asPublic()})
  }
  
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws {
    try await Role.query(on: req.db)
      .filter(\.$id ~~ ids.ids)
      .delete()
  }
  
  func update(param: InUpdateRole, ownerId: Role.IDValue) async throws {
    try await Role.query(on: req.db)
      .set(\.$name, to: param.name)
      .filter(\.$id == param.id)
      .update()
  }
  
  func all(ownerId: User.IDValue?) async throws -> [Role.Public] {
    return try await Role.query(on: req.db)
        .all()
        .map({$0.asPublic()})
  }
}
