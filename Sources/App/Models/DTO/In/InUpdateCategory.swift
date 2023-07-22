//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Foundation
import Vapor

struct InUpdateCategory: In {
  let name: String  // tag 名称
  let id: UUID // tag 的id
  let isNav: Bool 
}

extension InUpdateCategory: Validatable {
    static func validations(_ validations: inout Validations) {
      validations.add("name", as: String.self, is: .count(1...50))
      validations.add("id", as: String.self, is: !.empty)
    }
}
