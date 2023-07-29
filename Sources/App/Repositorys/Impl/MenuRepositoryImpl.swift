//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Foundation
import Vapor
import Fluent

struct MenuRepositoryImpl: MenuRepository {
  var req: Request
  
  init(_ req: Request) {
    self.req = req
  }
  
  func add(param: InMenu, ownerId: User.IDValue) async throws -> Menu {
    let item = Menu(name: param.name, url: param.url, weight: param.weight.castInt(), parentId: param.parentId)
    try await item.create(on: req.db)
    return item
  }
  
  func page(ownerId: User.IDValue?) async throws -> FluentKit.Page<Menu.Public> {
    return try await Menu.query(on: req.db)
        .filter(\.$status == 1)
        .sort(\.$weight, .descending)
        .sort(\.$createdAt, .descending)
        .paginate(for:req)
        .map({$0.asPublic()})
  }
  
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws {
    try await Menu.query(on: req.db)
      .set(\.$status, to: 0)
      .group(.and) { group in
        group.filter(\.$id ~~ ids.ids)
      }
      .update()
  }
  
  func update(param: InUpdateMenu, ownerId: User.IDValue) async throws {
    try await Menu.query(on: req.db)
      .set(\.$name, to: param.name)
      .set(\.$weight, to: param.weight.castInt())
      .set(\.$url, to: param.url)
      .set(\.$status, to: param.status)
      .filter(\.$id == param.id)
      .update()
  }
  
  func all(ownerId: User.IDValue?) async throws -> [Menu.Public] {
    return try await Menu.query(on: req.db)
        .filter(\.$status == 1)
        .sort(\.$weight, .descending)
        .all()
        .map({$0.asPublic()})
  }
}
