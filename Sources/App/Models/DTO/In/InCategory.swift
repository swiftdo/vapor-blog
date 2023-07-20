//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Foundation
import Vapor

struct InCategory: In {
    let name: String  // 名称
}

extension InCategory: Validatable {
    static func validations(_ validations: inout Validations) {
      validations.add("name", as: String.self, is: .count(1...10))
    }
}
