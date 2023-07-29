//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Foundation

extension Role {
  struct Public {
    let id: Role.IDValue?
    let name: String
    let desc: String?
  }
  
  func asPublic() -> Public {
    return Public(id: self.id, name: self.name, desc: self.desc)
  }
}
