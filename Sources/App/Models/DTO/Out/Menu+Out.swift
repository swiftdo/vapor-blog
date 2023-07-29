//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Foundation

extension Menu {
  struct Public: Out {
    let id: UUID?
    let name: String
    let url: String
    let weight: Int
    let parentId: Menu.IDValue?
  }
  
  func asPublic() -> Public {
    return Public(id: self.id, name: self.name, url: self.url,  weight: self.weight, parentId: self.$parent.id)
  }
}
