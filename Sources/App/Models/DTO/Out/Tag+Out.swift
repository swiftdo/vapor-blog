//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/9.
//

import Vapor

extension Tag {
  struct Public: Out {
    let id: UUID?
    let name: String
    let status: Int
    let ownerId: UUID
    let owner: User.Public?
  }
  
  func asPublic() -> Public {
      return Public(
          id: self.id,
          name: self.name,
          status: self.status,
          ownerId: self.$owner.id,
          owner: self.$owner.value?.asPublic()
      )
  }
  
}
