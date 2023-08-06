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
  
  init(name: String, code: String, desc: String? = nil) {
    self.name = name
    self.code = code
    self.desc = desc
  }
}

extension InPermission: Validatable {
    static func validations(_ validations: inout Validations) {
      
    }
}
