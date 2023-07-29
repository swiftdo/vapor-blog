//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor

struct InPermission: In {
  let name: String
  let code: String
  let desc: String?
}

extension InPermission: Validatable {
    static func validations(_ validations: inout Validations) {
      
    }
}
