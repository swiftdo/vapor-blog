//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/3.
//

import Vapor
import Fluent

struct ReplyRepositoryImpl: ReplyRepository {
  var req: Request
  
  init(_ req: Request) {
    self.req = req
  }
  
  func add(param: InReply, fromUserId: User.IDValue) async throws -> Reply {
    let reply = Reply(commentId: param.commentId,
                      content: param.content,
                      userId: fromUserId,
                      toUid: param.toUserId,
                      targetId: param.targetId,
                      targetType: param.targetType.castInt())
    try await reply.create(on: req.db)
    return reply
  }
  
  func all(commentId: Comment.IDValue) async throws -> [Reply.Public] {
    let replys = try await Reply.query(on: req.db)
      .filter(\.$comment.$id == commentId)
      .with(\.$toUser)
      .with(\.$fromUser)
      .with(\.$comment)
      .all()
    return replys.map({$0.asPublic()})
  }
  
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws {
    try await Reply.query(on: req.db).filter(\.$id ~~ ids.ids).delete()
  }
}
