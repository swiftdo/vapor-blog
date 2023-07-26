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
  
  func add(param: InLink, ownerId: User.IDValue) async throws -> Link {
    let link = Link(title: param.title, href: param.href, weight: param.weight.castInt(), ownerId: ownerId)
    try await link.create(on: req.db)
    return link
  }
  
  func page(ownerId: User.IDValue) async throws -> FluentKit.Page<Link.Public> {
    return try await Link.query(on: req.db)
        .with(\.$owner)
        .filter(\.$status == 1)
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
  
  func update(param: InUpdateLink, ownerId: User.IDValue) async throws {
    try await Link.query(on: req.db)
      .set(\.$title, to: param.title)
      .set(\.$weight, to: param.weight)
      .set(\.$href, to: param.href)
      .filter(\.$id == param.id)
      .update()
  }
  
  func all(ownerId: User.IDValue?) async throws -> [Link.Public] {
    return try await Link.query(on: req.db)
        .filter(\.$status == 1)
        .sort(\.$weight, .descending)
        .all()
        .map({$0.asPublic()})
  }
}
