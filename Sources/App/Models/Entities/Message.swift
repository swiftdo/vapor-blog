//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//

import Fluent
import Vapor

/// 通知记录
final class Message: Model {
  
  static let schema = "blog_message"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: FieldKeys.status)
  var status: Int // 1已查看，0未查看
  
  @Parent(key: FieldKeys.senderId)
  var sender: User
  
  @Parent(key: FieldKeys.receiverId)
  var receiver: User // 正常|删除
  
  @Parent(key: FieldKeys.msgInfoId)
  var messageInfo: MessageInfo // 消息内容

  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?
  
  @Timestamp(key: FieldKeys.updatedAt, on: .update)
  var updatedAt: Date?
  
  init() { }
  
  init(id: UUID? = nil, senderId: User.IDValue, receiverId: User.IDValue, msgInfoId: MessageInfo.IDValue, status: Int = 0) {
    self.id = id
    self.$sender.id = senderId
    self.$messageInfo.id = msgInfoId
    self.$receiver.id = receiverId
    self.status = 0
  }
}

extension Message {
  struct FieldKeys {
    static var status: FieldKey { "status" }
    static var senderId: FieldKey { "sender_id" }
    static var receiverId: FieldKey { "receiver_id" }
    static var msgInfoId: FieldKey { "msg_info_id" }
    static var createdAt: FieldKey { "created_at" }
    static var updatedAt: FieldKey { "updated_at" }
  }
}
