//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/14.
//

import Vapor

struct InCode: In {
    let email: String
}

extension InCode: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}
