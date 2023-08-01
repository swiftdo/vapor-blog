//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//

import Vapor

extension Comment {
  
  struct Public: Out {
    let id: UUID?
    let status: Int
    let content: String
    let topicId: UUID
    let topicType: Int
    let fromUid: UUID
    let fromUser: User.Public?
    let createdAt: Date?
  }
  
  func asPublic() -> Public {
    return Public(id: self.id,
                  status: self.status,
                  content: self.content,
                  topicId: self.topicId,
                  topicType: self.topicType,
                  fromUid: self.$fromUser.id,
                  fromUser: self.$fromUser.value?.asPublic(),
                  createdAt: self.createdAt
    )
  }

}
