//
//  File.swift
//
//
//  Created by laijihua on 2023/6/10.
//

import Fluent
import Vapor

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

  // 邀请码 inviteCode
  @OptionalField(key: FieldKeys.inviteCode)
  var inviteCode: String?

  // 上级ID superiorId
  @OptionalField(key: FieldKeys.superiorId)
  var superiorId: UUID?

  // 注册时间
  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?

  @Timestamp(key: FieldKeys.updatedAt, on: .update)
  var updatedAt: Date?

  init() {}

  init(
    id: UUID? = nil, name: String, email: String, status: Int = 1, isAdmin: Bool = false,
    isEmailVerified: Bool = false, inviteCode: String? = nil, superiorId: UUID? = nil
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.status = status
    self.isAdmin = isAdmin
    self.isEmailVerified = isEmailVerified
    self.inviteCode = inviteCode
    self.superiorId = superiorId
  }
}

extension User {
  struct FieldKeys {
    static var name: FieldKey { "name" }
    static var email: FieldKey { "email" }
    static var isEmailVerified: FieldKey { "is_email_verified" }
    static var status: FieldKey { "status" }
    static var isAdmin: FieldKey { "is_admin" }
    static var inviteCode: FieldKey { "invite_code" }
    static var superiorId: FieldKey { "superior_id" }
    static var createdAt: FieldKey { "created_at" }
    static var updatedAt: FieldKey { "updated_at" }
  }
}
