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
    
    @Field(key: FieldKeys.name)
    var name: String
    
    @Field(key: FieldKeys.email)
    var email: String
    
    @Field(key: FieldKeys.isEmailVerified)
    var isEmailVerified: Bool  // 邮箱状态
    
    @Field(key: FieldKeys.status)
    var status: Int  // 1正常用户；2其他非正常用户
    
    @Field(key: FieldKeys.isAdmin)
    var isAdmin: Bool  // 是否是管理员
    
    // 注册时间
        @Timestamp(key: FieldKeys.createdAt, on: .create)
        var createdAt: Date?

        @Timestamp(key: FieldKeys.updatedAt, on: .update)
        var updatedAt: Date?
    
    init(){}
    
    init(id: UUID? = nil, name: String, email: String, status: Int = 1, isAdmin: Bool = false, isEmailVerified: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.status = status
        self.isAdmin = isAdmin
        self.isEmailVerified = isEmailVerified
    }
}

extension User {
    struct FieldKeys {
        static var name: FieldKey { "name"}
        static var email: FieldKey { "email" }
        static var isEmailVerified: FieldKey { "is_email_verified" }
        static var status: FieldKey { "status" }
        static var isAdmin: FieldKey { "is_admin" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}


