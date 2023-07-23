//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor
import Fluent

struct LinkRepositoryImpl: LinkRepository {
  var req: Request
  
  init(_ req: Request) {
      self.req = req
  }
  
  func add(in: InLink, ownerId: User.IDValue) async throws -> Link {
    let link = Link(title: in.title, href: in.href, ownerId: ownerId)
    try await link.create(on: req.db)
    return link
  }
  
  func page(ownerId: User.IDValue) async throws -> FluentKit.Page<Link.Public> {
    return try await Link.query(on: req.db)
        .group(.and) { group in
          // status 1是正常, 2是删除
          group.filter(\.$owner.$id == ownerId).filter(\.$status == 1)
        }
        .sort(\.$createdAt, .descending)
        .paginate(for:req)
        .map({$0.asPublic()})
  }
  
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws {
    try await Link.query(on: req.db)
      .set(\.$status, to: 0)
      .group(.and) {group in
        group.filter(\.$id ~~ ids.ids).filter(\.$owner.$id == ownerId)
      }
      .update()
  }
  
  func update(in: InUpdateLink, ownerId: User.IDValue) async throws {
    try await Link.query(on: req.db)
      .set(\.$title, to: in.title)
      .set(\.$weight, to: in.weight)
      .set(\.$href, to: in.href)
      .filter(\.$id == in.id)
      .update()
  }
}
