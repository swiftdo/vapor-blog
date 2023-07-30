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
    let permissions: [Permission.Public]?
    let permissionIds: [UUID]?
  }
  
  func asPublic() -> Public {
    return Public(id: self.id,
                  name: self.name,
                  desc: self.desc,
                  permissions: self.$permissions.value?.map({$0.asPublic()}),
                  permissionIds: self.$permissions.value?.map({$0.id!})
    )
  }
}
