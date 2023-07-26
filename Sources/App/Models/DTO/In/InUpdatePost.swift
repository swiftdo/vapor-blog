//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Foundation
import Vapor

struct InUpdatePost: In {
  let title: String  // 名称
  let id: UUID // tag 的id
  let desc: String
  let content: String
  let categoryId: UUID
  let tagIds: [UUID]
}

extension InUpdatePost: Validatable {
    static func validations(_ validations: inout Validations) {
      validations.add("title", as: String.self, is: .count(1...100))
      validations.add("id", as: String.self, is: !.empty)
    }
}
