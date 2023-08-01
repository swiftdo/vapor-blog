//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//

import Vapor

extension Reply {
  
  struct Public: Out {
    let id: UUID?
    let status: Int
    let content: String
    let targetId: UUID
    let targetType: Int
    let fromUid: UUID
    let toUid: UUID?
    let fromUser: User.Public?
    let toUser: User.Public?
    let commentId: UUID
    let comment: Comment.Public?
  }
  
  func asPublic() -> Public {
    return Public(id: self.id,
                  status: self.status,
                  content: self.content,
                  targetId: self.targetId,
                  targetType: self.targetType,
                  fromUid: self.$fromUser.id,
                  toUid: self.$toUser.id,
                  fromUser: self.$fromUser.value?.asPublic(),
                  toUser: self.$toUser.value??.asPublic(),
                  commentId: self.$comment.id,
                  comment: self.$comment.value?.asPublic()
    )
  }
  
}
