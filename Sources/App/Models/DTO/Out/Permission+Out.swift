//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Foundation

extension Permission {
  struct Public: Out {
    let id: UUID?
    let name: String
    let code: String
    let desc: String?
  }
  
  func asPublic() -> Public {
    return Public(id: self.id, name: self.name, code: self.code, desc: self.desc)
  }
}
