//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//

import Vapor

extension MessageInfo {
  
  struct Public: Out {
    let id: UUID?
    let targetId: UUID?
    let title: String
    let content: String
    let msgType: Int
    let createdAt: Date?
    
  }
  
  func asPublic() -> Public {
    return Public(id: self.id,
                  targetId: self.targetId,
                  title: self.title,
                  content: self.content,
                  msgType: self.msgType,
                  createdAt: self.createdAt
    )
  }
  
}
