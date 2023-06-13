//
//  File.swift
//
//
//  Created by laijihua on 2022/8/30.
//

import Fluent
import Vapor

/// 用户认证状态
final class UserAuth: Model {
    static let schema = "blog_user_auth"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.userId)
    var user: User

    @Field(key: FieldKeys.authType)
    var authType: String  // 认证类型：email

    @Field(key: FieldKeys.identifier)
    var identifier: String  // 标志 (手机号，邮箱，用户名或第三方应用的唯一标识)

    @Field(key: FieldKeys.credential)
    var credential: String  // 密码凭证(站内的保存密码， 站外的不保存或保存 token)

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        authType: String = "email",
        identifier: String,
        credential: String
    ) {
        self.id = id
        self.$user.id = userId
        self.authType = authType
        self.identifier = identifier
        self.credential = credential
    }
}

extension UserAuth {
    struct FieldKeys {
        static var userId: FieldKey { "user_id" }
        static var authType: FieldKey { "auth_type" }
        static var identifier: FieldKey { "identifier" }
        static var credential: FieldKey { "credential" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
