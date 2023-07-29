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
  let weight: Int
  let url: String

}

extension InMenu: Validatable {
    static func validations(_ validations: inout Validations) {
      
    }
}
