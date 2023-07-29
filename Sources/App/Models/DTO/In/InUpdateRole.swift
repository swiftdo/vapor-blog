//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor

struct InUpdateRole: In {
  let name: String
  let id: UUID
}

extension InUpdateRole: Validatable {
    static func validations(_ validations: inout Validations) {
      
    }
}

