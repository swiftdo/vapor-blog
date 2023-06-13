//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Vapor

struct ApiError {
    var content: OutStatus

    init(code: OutStatus) {
        self.content = code
    }
}

extension ApiError: AbortError {
    var status: HTTPResponseStatus { .ok }
    var reason: String {
        return self.content.message
    }
}
