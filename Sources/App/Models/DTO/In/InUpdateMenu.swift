//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//
import Vapor

struct InUpdateMenu: In {
  let id: UUID
  let name: String
  let parentId: UUID?
  let weight: SpecInt
  let url: String
  let status: Int
}

extension InUpdateMenu: Validatable {
    static func validations(_ validations: inout Validations) {
      
    }
}
