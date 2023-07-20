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
  
  func add(inCategory: InCategory, ownerId: User.IDValue) async throws -> Category {
    let category = Category(name: inCategory.name, ownerId: ownerId)
    try await category.create(on: req.db)
    return category
  }
  
  func page(ownerId: User.IDValue) async throws -> FluentKit.Page<Category.Public> {
    return try await Category.query(on: req.db)
      .group(.and) {group in
        group.filter(\.$owner.$id == ownerId).filter(\.$status == 1)
      }
      .sort(\.$createdAt, .descending)
      .paginate(for: req)
      .map({$0.asPublic()})
  }
  
  func delete(categoryIds: InDeleteIds, ownerId: User.IDValue) async throws {
      try await Category.query(on: req.db)
        .set(\.$status, to: 0)
        .group(.and) {group in
          group.filter(\.$id ~~ categoryIds.ids).filter(\.$owner.$id == ownerId)
        }
        .update()
  }
  
  func update(category: InUpdateCategory) async throws {
    try await Category.query(on: req.db)
      .set(\.$name, to: category.name)
      .set(\.$isNav, to: category.isNav)
      .filter(\.$id == category.id)
      .update()
  }
}

