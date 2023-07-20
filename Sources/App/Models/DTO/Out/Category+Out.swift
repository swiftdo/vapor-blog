//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor

extension Category {
  struct Public: Out {
    let id: UUID?
    let name: String
    let status: Int
    let ownerId: UUID
    let isNav: Bool
  }
  
  func asPublic() -> Public {
    return Public(
      id: self.id,
      name: self.name,
      status: self.status,
      ownerId: self.$owner.id,
      isNav: self.isNav
    )
  }
}
