//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor

extension Post {
  struct Public: Out {
    let id: UUID?
    let title: String
    let status: Int
    let ownerId: UUID
    let desc: String
    let content: String
    let categoryId: UUID
  }
  
  func asPublic() -> Public {
    return Public(
      id: self.id,
      title: self.title,
      status: self.status,
      ownerId: self.$owner.id,
      desc: self.desc,
      content: self.content,
      categoryId: self.$category.id
    )
  }
}
