//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Foundation
import Vapor

struct InPost: In {
  let title: String  // 名称
  let content: String
  let desc: String
  let categoryId: UUID
  let tagIds: [UUID]
}

extension InPost: Validatable {
    static func validations(_ validations: inout Validations) {
      validations.add("title", as: String.self, is: .count(1...100))
    }
}
