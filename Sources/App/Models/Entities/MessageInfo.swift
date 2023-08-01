//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//


import Fluent
import Vapor

/// 通知详情
final class MessageInfo: Model {
  
  static let schema = "blog_message_info"
  
  @ID(key: .id)
  var id: UUID?
  
  @OptionalField(key: FieldKeys.targetId)
  var targetId: UUID?
  
  @Field(key: FieldKeys.title)
  var title: String
  
  @Field(key: FieldKeys.content)
  var content: String
  
  @Field(key: FieldKeys.msgType)
  var msgType: Int // 1评论，2回复评论，3关注，4喜欢，5系统通知
  
  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?
  
  @Timestamp(key: FieldKeys.updatedAt, on: .update)
  var updatedAt: Date?
  
  init() { }
  
  init(id: UUID? = nil, targetId: UUID?, msgType: Int, title: String, content: String) {
    self.id = id
    self.targetId = targetId
    self.msgType = msgType
    self.title = title
    self.content = content
  }
}

extension MessageInfo {
  struct FieldKeys {
    static var targetId: FieldKey { "target_id" }
    static var title: FieldKey { "title" }
    static var content: FieldKey { "content" }
    static var msgType: FieldKey { "msg_type"}
    static var createdAt: FieldKey { "created_at" }
    static var updatedAt: FieldKey { "updated_at" }
  }
}
