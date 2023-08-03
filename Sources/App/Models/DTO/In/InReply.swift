//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/3.
//

import Foundation
import Vapor

struct InReply: In {
  let commentId: UUID // 根评论id
  let content: String
  let toUserId: UUID? // @xxx
  let targetId: UUID // 评论id, 或者回复id
  let targetType: Int  // 1: 评论 2：回复
}

extension InReply: Validatable {
    static func validations(_ validations: inout Validations) {
        
    }
}
