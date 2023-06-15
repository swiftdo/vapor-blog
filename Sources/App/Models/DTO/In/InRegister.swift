//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Vapor

struct InRegister: In {
    var name: String
    var email: String
    var password: String
    var code: String
}

extension InRegister: Validatable {
    // API 解码数据之前，对传入的请求进行验证
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
        validations.add("code", as: String.self, is: !.empty)
    }
}

