//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//

import Vapor

extension Message {
  
  struct Public: Out {
    let id: UUID?
    let status: Int
    let senderId: UUID
    let receiverId: UUID
    let messageInfoId: UUID
    let createdAt: Date?
    let receiver: User.Public?
    let sender: User.Public?
    
  }
  
  func asPublic() -> Public {
    return Public(id: self.id,
                  status: self.status,
                  senderId: self.$sender.id,
                  receiverId: self.$receiver.id,
                  messageInfoId: self.$messageInfo.id,
                  createdAt: self.createdAt,
                  receiver: self.$receiver.value?.asPublic(),
                  sender: self.$sender.value?.asPublic())
  }
  
}
