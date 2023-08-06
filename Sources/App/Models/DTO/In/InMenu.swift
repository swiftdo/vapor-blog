//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor

struct InMenu: In {
  
  let name: String
  let parentId: UUID?
  let weight: SpecInt
  let url: String
  
  init(name: String, weight: Int, url: String, parentId: UUID? = nil) {
    self.name = name
    self.weight = .int(weight)
    self.url = url
    self.parentId = parentId
  }

}

extension InMenu: Validatable {
    static func validations(_ validations: inout Validations) {
      
    }
}
