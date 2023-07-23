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
  
  func add(inPost: InPost, ownerId: User.IDValue) async throws -> Post {
    let post = Post(title: inPost.title, ownerId: ownerId, content: inPost.content, desc: inPost.desc, categoryId: inPost.categoryId)
    let tags = try await Tag.query(on: req.db).filter(\.$id ~~ inPost.tagIds).all()
    try await req.db.transaction { db in
      try await post.create(on: db)
      try await post.$tags.attach(tags, on: db)
    }
    return post
  }
  
  func page(ownerId: User.IDValue) async throws -> FluentKit.Page<Post.Public> {
    return try await Post.query(on: req.db)
        .group(.and) { group in
          // status 1是正常, 2是删除
          group.filter(\.$owner.$id == ownerId).filter(\.$status == 1)
        }
        .sort(\.$createdAt, .descending)
        .with(\.$tags)
        .with(\.$category)
        .paginate(for: req)
        .map({ $0.asPublic() })
  }
  
  func delete(postIds: InDeleteIds, ownerId: User.IDValue) async throws {
    try await Post.query(on: req.db)
      .set(\.$status, to: 0)
      .group(.and) {group in
        group.filter(\.$id ~~ postIds.ids).filter(\.$owner.$id == ownerId)
      }
      .update()
  }
  
  func update(post: InUpdatePost) async throws {
    
    try await req.db.transaction { db in
      try await Post.query(on: db)
        .set(\.$title, to: post.title)
        .set(\.$desc, to: post.desc)
        .set(\.$content, to: post.content)
        .set(\.$category.$id, to: post.categoryId)
        .filter(\.$id == post.id)
        .update()
      
      guard let ret = try await Post.query(on: db)
        .with(\.$tags)
        .filter(\.$id == post.id)
        .first()
      else {
        throw ApiError(code: .postNotExist)
      }
      
      try await ret.$tags.detachAll(on: db)
      let newTags = try await Tag.query(on: db).filter(\.$id ~~ post.tagIds).all()
      try await ret.$tags.attach(newTags, on: db)
    }
  }
//  private func asPublic(_ post: Post, req: Request) async throws -> Post.Public {
//    let tagIds = try await self.$tags.get(on: req.db).map { tag in try tag.requireID() }
//    return post.asPublicWith(tagIds: tagIds)
//  }
  
  
}
