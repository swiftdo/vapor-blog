//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/9.
//

import Vapor
import Fluent

struct TagRepositoryImpl: TagRepository {
  var req: Request
  
  init(_ req: Request) {
      self.req = req
  }
  
  func add(in: InTag, ownerId: User.IDValue) async throws -> Tag {
    let tag = Tag(name: in.name, ownerId: ownerId)
    try await tag.create(on: req.db)
    return tag
  }
  
  func page(ownerId: User.IDValue) async throws -> Page<Tag.Public> {
    return try await Tag.query(on: req.db)
        .filter(\.$status == 1)
        .with(\.$owner)
        .sort(\.$createdAt, .descending)
        .paginate(for:req)
        .map({$0.asPublic()})
  }
  
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws {
      try await Tag.query(on: req.db)
        .set(\.$status, to: 0)
        .group(.and) {group in
          group.filter(\.$id ~~ ids.ids).filter(\.$owner.$id == ownerId)
        }
        .update()
  }
  
  func update(in: InUpdateTag, ownerId: User.IDValue) async throws {
    try await Tag.query(on: req.db)
      .set(\.$name, to: in.name)
      .filter(\.$id == in.id)
      .update()
  }
  
  func all(ownerId: User.IDValue) async throws -> [Tag.Public] {
    try await Tag.query(on: req.db)
      .sort(\.$createdAt, .descending)
      .all()
      .map({$0.asPublic()})
  }
}
