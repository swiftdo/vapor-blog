//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/3.
//

import Foundation
import Vapor

struct InComment: In {
  let topicId: UUID
  let content: String
  let topicType: Int // 1: 文章
}

extension InComment: Validatable {
    static func validations(_ validations: inout Validations) {
        
    }
}

