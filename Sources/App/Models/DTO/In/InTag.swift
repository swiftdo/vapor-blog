//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/9.
//

import Foundation
import Vapor

struct InTag: In {
    let name: String  // tag 名称
}

extension InTag: Validatable {
    static func validations(_ validations: inout Validations) {
      validations.add("name", as: String.self, is: .count(1...10))
    }
}
