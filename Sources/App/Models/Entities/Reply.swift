//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/1.
//

import Fluent
import Vapor

final class Reply: Model {
    
    static let schema = "blog_reply"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.status)
    var status: Int // 正常(1)|删除(0)
    
    @Field(key: FieldKeys.content)
    var content: String
    
    @Field(key: FieldKeys.targetId)
    var targetId: UUID
    
    @Field(key: FieldKeys.targetType)
    var targetType: Int // 1: 评论 2：回复
    
    @Parent(key: FieldKeys.fromUid)
    var fromUser: User
    
    @OptionalParent(key: FieldKeys.toUid)
    var toUser: User?
    
    @Parent(key: FieldKeys.commentId)
    var comment: Comment // 根评论
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() { }

    init(id: UUID? = nil, commentId: Comment.IDValue, content: String, userId: User.IDValue, toUid: User.IDValue?, targetId: UUID, targetType: Int, status: Int = 1) throws {
        self.id = id
        self.$comment.id = commentId
        self.content = content
        self.$fromUser.id = userId
        self.targetId = targetId
        self.targetType = targetType
        self.$toUser.id = toUid
        self.status = status
    }
}

extension Reply {
    struct FieldKeys {
        static var status: FieldKey { "status" }
        static var commentId: FieldKey { "comment_id" }
        static var targetId: FieldKey { "target_id" }
        static var targetType: FieldKey { "target_type" }
        static var content: FieldKey { "content" }
        static var fromUid: FieldKey { "from_uid" }
        static var toUid: FieldKey { "to_uid" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
