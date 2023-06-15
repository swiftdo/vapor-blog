//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/14.
//

import Vapor

struct InUpdatepwd: In {
    let email: String  // 邮箱
    let pwd: String  // 旧密码
    let newpwd: String  // 新密码
}

extension InUpdatepwd: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("pwd", as: String.self, is: .count(8...))
        validations.add("newpwd", as: String.self, is: .count(8...))
    }
}

