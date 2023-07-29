//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor

struct InRole: In {
  let name: String
}

extension InRole: Validatable {
    static func validations(_ validations: inout Validations) {
      
    }
}

