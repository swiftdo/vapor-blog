//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/14.
//
import Fluent
import Vapor

/// 邮箱验证码
final class EmailCode: Model {
    static var schema: String = "blog_email_codes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.email)
    var email: String

    @Field(key: FieldKeys.code)
    var code: String

    @Field(key: FieldKeys.type)
    var type: String  // register, resetpwd

    @Field(key: FieldKeys.status)
    var status: Int  // 1 为已使用，0 为未使用，默认为 0

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, email: String, code: String, status: Int = 0, type: String) {
        self.id = id
        self.email = email
        self.code = code
        self.status = status
        self.type = type
    }
}

extension EmailCode {
    struct FieldKeys {
        static var email: FieldKey { "email" }
        static var code: FieldKey { "code" }
        static var type: FieldKey { "type" }
        static var status: FieldKey { "status" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
