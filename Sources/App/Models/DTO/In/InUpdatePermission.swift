//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//
import Vapor

struct InUpdatePermission: In {
  let name: String
  let code: String
  let desc: String?
  let id: UUID
}

extension InUpdatePermission: Validatable {
    static func validations(_ validations: inout Validations) {
      
    }
}
