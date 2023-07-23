//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor
import Fluent

struct PostRepositoryImpl: PostRepository {
  
  var req: Request
  
  init(_ req: Request) {
      self.req = req
  }
  
  func add(in: InPost, ownerId: User.IDValue) async throws -> Post {
    let post = Post(title: in.title, ownerId: ownerId, content: in.content, desc: in.desc, categoryId: in.categoryId)
    let tags = try await Tag.query(on: req.db).filter(\.$id ~~ in.tagIds).all()
    try await req.db.transaction { db in
      try await post.create(on: db)
      try await post.$tags.attach(tags, on: db)
    }
    return post
  }
  
  func page(ownerId: User.IDValue) async throws -> FluentKit.Page<Post.Public> {
    return try await Post.query(on: req.db)
        .filter(\.$status == 1)
        .sort(\.$createdAt, .descending)
        .with(\.$tags)
        .with(\.$category)
        .paginate(for: req)
        .map({ $0.asPublic() })
  }
  
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws {
    try await Post.query(on: req.db)
      .set(\.$status, to: 0)
      .group(.and) {group in
        group.filter(\.$id ~~ ids.ids).filter(\.$owner.$id == ownerId)
      }
      .update()
  }
  
  func update(in: InUpdatePost, ownerId: User.IDValue) async throws {
    try await req.db.transaction { db in
      try await Post.query(on: db)
        .set(\.$title, to: in.title)
        .set(\.$desc, to: in.desc)
        .set(\.$content, to: in.content)
        .set(\.$category.$id, to: in.categoryId)
        .filter(\.$id == in.id)
        .update()
      
      guard let ret = try await Post.query(on: db)
        .with(\.$tags)
        .filter(\.$id == in.id)
        .first()
      else {
        throw ApiError(code: .postNotExist)
      }
      
      try await ret.$tags.detachAll(on: db)
      let newTags = try await Tag.query(on: db).filter(\.$id ~~ in.tagIds).all()
      try await ret.$tags.attach(newTags, on: db)
    }
  }
}
