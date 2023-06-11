//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/10.
//

import Vapor
import Fluent

final class User: Model {
    
    static let schema = "blog_user"
    
    @ID(key: .id)
    var id: UUID?
    
    init(){}
}

extension User {
    
    struct FieldKeys {
        
    }
}


