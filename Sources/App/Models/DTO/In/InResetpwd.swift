//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/14.
//

import Vapor

struct InResetpwd: In {
    let email: String
    let pwd: String
    let code: String
}

extension InResetpwd: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("pwd", as: String.self, is: .count(8...))
        validations.add("code", as: String.self, is: !.empty)
    }
}

