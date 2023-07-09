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
  
  
  func add(inTag: InTag, ownerId: User.IDValue) async throws -> Tag {
    let tag = Tag(name: inTag.name, ownerId: ownerId)
    try await tag.create(on: req.db)
    return tag
  }
  
  func page(ownerId: User.IDValue) async throws -> Page<Tag.Public> {
    return try await Tag.query(on: req.db)
        .filter(\.$owner.$id == ownerId)
        .paginate(for:req)
        .map({$0.asPublic()})
  }
  
}
