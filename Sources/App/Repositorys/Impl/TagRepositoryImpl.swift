//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/9.
//

import Vapor
import Fluent
import FluentSQL

struct TagRepositoryImpl: TagRepository {
  var req: Request
  
  init(_ req: Request) {
      self.req = req
  }
  
  func add(param: InTag, ownerId: User.IDValue) async throws -> Tag {
    let tag = Tag(name: param.name, ownerId: ownerId)
    try await tag.create(on: req.db)
    return tag
  }
  
  func page(ownerId: User.IDValue?) async throws -> Page<Tag.Public> {
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
  
  func update(param: InUpdateTag, ownerId: User.IDValue) async throws {
    try await Tag.query(on: req.db)
      .set(\.$name, to: param.name)
      .filter(\.$id == param.id)
      .update()
  }
  
  func all(ownerId: User.IDValue?) async throws -> [Tag.Public] {
    try await Tag.query(on: req.db)
      .filter(\.$status == 1)
      .sort(\.$createdAt, .descending)
      .all()
      .map({$0.asPublic()})
  }
  
  func hot(limit: Int) async throws -> [Tag.Public] {
    if let sql = req.db as? SQLDatabase {
      // 底层数据库驱动程序是 SQL
      let query = """
      select tags.*
      from \(Tag.schema) tags
      left join \(PostTag.schema) pivot on tags.id = pivot.\(PostTag.FieldKeys.tagId)
      group by tags.id
      having count(pivot.\(PostTag.FieldKeys.tagId))  > 0
      order by count(pivot.\(PostTag.FieldKeys.tagId)) desc
      limit \(limit)
      """
      return try await sql.raw(.init(query)).all(decoding: Tag.self).map({$0.asPublic()})
    } else {
      throw ApiError(code: .postNotExist)
    }
  }
}
