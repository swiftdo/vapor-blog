//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor

extension Link {
  struct Public: Out {
    let id: UUID?
    let title: String
    let status: Int
    let ownerId: UUID
    let href: String
    let weight: Int
    let owner: User.Public?
  }
  
  func asPublic() -> Public {
    return Public(
      id: self.id,
      title: self.title,
      status: self.status,
      ownerId: self.$owner.id,
      href: self.href,
      weight: self.weight,
      owner: self.$owner.value?.asPublic()
    )
  }
}
