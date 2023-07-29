//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Foundation

extension Role {
  struct Public: Out {
    let id: UUID?
    let name: String
    let desc: String?
  }
  
  func asPublic() -> Public {
    return Public(id: self.id, name: self.name, desc: self.desc)
  }
}
