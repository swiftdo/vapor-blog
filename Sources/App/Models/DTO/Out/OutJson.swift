//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Vapor

struct OutJson<T: Out>: Out, OutCodeMsg {
    var code: Int
    var message: String
    let data: T?

    init(code: OutStatus, data: T?) {
        self.code = code.code
        self.message = code.message
        self.data = data
    }

    init(success data: T) {
        self.init(code: .ok, data: data)
    }

    init(error code: OutStatus) {
        self.init(code: code, data: nil)
    }
}
