//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/29.
//

import Foundation
import Vapor

struct InUpdateUser: In {
  let id: UUID
  let roleIds: [UUID] // 权限id
}

extension InUpdateUser: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}
