//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/17.
//

import Foundation
import Vapor

struct InUpdateTag: In {
  let name: String  // tag 名称
  let id: UUID // tag 的id
}

extension InUpdateTag: Validatable {
    static func validations(_ validations: inout Validations) {
      validations.add("name", as: String.self, is: .count(1...10))
      validations.add("id", as: String.self, is: !.empty)
    }
}
