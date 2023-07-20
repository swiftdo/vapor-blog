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
    //TODO: -tag 怎么处理
    let post = Post(title: inPost.title, ownerId: ownerId, content: inPost.content, desc: inPost.desc, categoryId: inPost.categoryId)
    try await post.create(on: req.db)
    return post
  }
  
  func page(ownerId: User.IDValue) async throws -> FluentKit.Page<Post.Public> {
    return try await Post.query(on: req.db)
        .group(.and) { group in
          // status 1是正常, 2是删除
          group.filter(\.$owner.$id == ownerId).filter(\.$status == 1)
        }
        .sort(\.$createdAt, .descending)
        .paginate(for:req)
        .map({$0.asPublic()})
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
    try await Post.query(on: req.db)
      .set(\.$title, to: post.title)
      .set(\.$desc, to: post.desc)
      .set(\.$content, to: post.content)
      .set(\.$category.$id, to: post.categoryId)
      .filter(\.$id == post.id)
      .update()
  }
  
  
}
