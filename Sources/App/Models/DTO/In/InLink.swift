//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Foundation
import Vapor

struct InLink: In {
  let title: String  // 名称
  let href: String // href
}

extension InLink: Validatable {
    static func validations(_ validations: inout Validations) {
      validations.add("title", as: String.self, is: .count(1...20))
    }
}
