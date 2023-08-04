//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/3.
//

import Vapor
import Fluent

struct CommentRepositoryImpl: CommentRepository {
  var req: Request
  
  init(_ req: Request) {
    self.req = req
  }
  
  func add(param: InComment, fromUserId: User.IDValue) async throws -> Comment {
    let comment = Comment(content: param.content, userId: fromUserId, topicId: param.topicId, topicType: param.topicType)
    try await comment.create(on: req.db)
    return comment
  }
  
  func all(topicId: UUID, topicType: Int) async throws -> [Comment.Public] {
    let comments = try await Comment.query(on: req.db)
      .filter(\.$topicId == topicId)
      .filter(\.$topicType == topicType)
      .with(\.$fromUser)
      .with(\.$replys, { reply in
        reply.with(\.$fromUser)
        reply.with(\.$toUser)
      })
      .sort(\.$createdAt, .descending)
      .all()
    return comments.map({$0.asPublic()})
  }
  
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws {
    try await Comment.query(on: req.db).filter(\.$id ~~ ids.ids).delete()
  }
}
