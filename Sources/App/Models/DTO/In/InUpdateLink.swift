//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Foundation
import Vapor

struct InUpdateLink: In {
  let title: String  // tag 名称
  let href: String
  let weight: Int 
  let id: UUID // tag 的id
}

extension InUpdateLink: Validatable {
    static func validations(_ validations: inout Validations) {
      validations.add("title", as: String.self, is: .count(1...10))
      validations.add("id", as: String.self, is: !.empty)
    }
}
