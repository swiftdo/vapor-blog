//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

protocol OutCodeMsg {
    var code: Int { get }
    var message: String { get }
}

struct OutStatus: Out, OutCodeMsg {
    var code: Int
    var message: String

    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

// 状态值
extension OutStatus {
    static var ok = OutStatus(code: 0, message: "请求成功")
    static var userExist = OutStatus(code: 20, message: "用户已经存在")
    static var userNotExist = OutStatus(code: 21, message: "用户不存在")
}
