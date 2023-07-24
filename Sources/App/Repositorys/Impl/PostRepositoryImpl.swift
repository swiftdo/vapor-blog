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
  
  func add(param: InPost, ownerId: User.IDValue) async throws -> Post {
    let post = Post(title: param.title, ownerId: ownerId, content: param.content, desc: param.desc, categoryId: param.categoryId)
    let tags = try await Tag.query(on: req.db).filter(\.$id ~~ param.tagIds).all()
    try await req.db.transaction { db in
      try await post.create(on: db)
      try await post.$tags.attach(tags, on: db)
    }
    return post
  }
  
  func page(ownerId: User.IDValue?, inIndex: InSearchPost?) async throws -> FluentKit.Page<Post.Public> {
    
    let pageQuery = Post.query(on: req.db)
      .filter(\.$status == 1)
    
    if let inIndex = inIndex {
      if let cateId = inIndex.categoryId {
        pageQuery.filter(\.$category.$id == cateId)
      }
    }
    
    return try await pageQuery
        .sort(\.$createdAt, .descending)
        .with(\.$tags)
        .with(\.$category)
        .with(\.$owner)
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
  
  func update(param: InUpdatePost, ownerId: User.IDValue) async throws {
    try await req.db.transaction { db in
      try await Post.query(on: db)
        .set(\.$title, to: param.title)
        .set(\.$desc, to: param.desc)
        .set(\.$content, to: param.content)
        .set(\.$category.$id, to: param.categoryId)
        .filter(\.$id == param.id)
        .update()
      
      guard let ret = try await Post.query(on: db)
        .with(\.$tags)
        .filter(\.$id == param.id)
        .first()
      else {
        throw ApiError(code: .postNotExist)
      }
      
      try await ret.$tags.detachAll(on: db)
      let newTags = try await Tag.query(on: db).filter(\.$id ~~ param.tagIds).all()
      try await ret.$tags.attach(newTags, on: db)
    }
  }
  
  func get(id: Post.IDValue, ownerId: User.IDValue?) async throws -> Post.Public? {
    let post = try await Post.query(on: req.db)
      .filter(\.$id == id)
      .with(\.$owner)
      .with(\.$category)
      .with(\.$tags)
      .first()
    return post?.asPublic()
  }
}
