//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor
import FluentKit

extension Post {
  struct Public: Out {
    let id: UUID?
    let title: String
    let status: Int
    let ownerId: UUID
    let desc: String
    let content: String
    let categoryId: UUID
    let tagIds: [UUID]
    let category: Category.Public
    let tags: [Tag.Public]
    let owner: User.Public?
  }
  
  func asPublic() -> Public {
    return Public(
      id: self.id,
      title: self.title,
      status: self.status,
      ownerId: self.$owner.id,
      desc: self.desc,
      content: self.content,
      categoryId: self.$category.id,
      tagIds: self.tags.map{ $0.id! },
      category: self.category.asPublic(),
      tags: self.tags.map { $0.asPublic() },
      owner: self.$owner.value?.asPublic()
    )
  }
}
