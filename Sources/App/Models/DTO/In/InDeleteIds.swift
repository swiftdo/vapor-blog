//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/17.
//

import Vapor

struct InDeleteIds: In {
  let ids: [UUID]
}

extension InDeleteIds: Validatable {
    static func validations(_ validations: inout Validations) {
      validations.add("ids", as: [UUID].self, is: !.empty)
    }
}
