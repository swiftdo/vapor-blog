//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/23.
//

import Foundation
import Vapor
import Fluent

final class Invite: Model {
    static var schema: String = "blog_invites"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.code)
    var code:String
    
    init() {}
    
    init(code: String) {
        self.code = code
    }
}


extension Invite {
    struct FieldKeys {
        static var code: FieldKey { "code" }
    }
}
