//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor
import Fluent

struct CategoryRepositoryImpl: CategoryRepository {
  
  var req: Request
  
  init(_ req: Request) {
      self.req = req
  }
  
  func add(in: InCategory, ownerId: User.IDValue) async throws -> Category {
    let category = Category(name: in.name, ownerId: ownerId, isNav: in.isNav)
    try await category.create(on: req.db)
    return category
  }
  
  func page(ownerId: User.IDValue) async throws -> FluentKit.Page<Category.Public> {
    return try await Category.query(on: req.db)
      .filter(\.$status == 1)
      .sort(\.$createdAt, .descending)
      .paginate(for: req)
      .map({$0.asPublic()})
  }
  
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws {
      try await Category.query(on: req.db)
        .set(\.$status, to: 0)
        .group(.and) {group in
          group.filter(\.$id ~~ ids.ids).filter(\.$owner.$id == ownerId)
        }
        .update()
  }
  
  func update(in: InUpdateCategory, ownerId: User.IDValue) async throws {
    try await Category.query(on: req.db)
      .set(\.$name, to: in.name)
      .set(\.$isNav, to: in.isNav)
      .filter(\.$id == in.id)
      .update()
  }
  
  func all(ownerId: User.IDValue) async throws -> [Category.Public] {
    try await Category.query(on: req.db)
      .sort(\.$createdAt, .descending)
      .all()
      .map({$0.asPublic()})
  }
}

