//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/9.
//

import Fluent
import Vapor

final class Comment: Model {
    
    static let schema = "blog_comment"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.status)
    var status: Int // 正常(1)|删除(0)
    
    @Field(key: FieldKeys.content)
    var content: String
    
    @Field(key: FieldKeys.topicId)
    var topicId: UUID
    
    @Field(key: FieldKeys.topicType)
    var topicType: Int // 1: 文章
    
    @Parent(key: FieldKeys.fromUid)
    var fromUser: User
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() { }

    init(id: UUID? = nil, content: String, userId: UUID, topicId: UUID, topicType: Int, status: Int = 1) throws {
        self.id = id
        self.content = content
        self.$fromUser.id = userId
        self.topicId = topicId
        self.topicType = topicType
        self.status = status
    }
}

extension Comment {
    struct FieldKeys {
        static var status: FieldKey { "status" }
        static var topicId: FieldKey { "topic_id" }
        static var topicType: FieldKey { "topic_type" }
        static var content: FieldKey { "content" }
        static var fromUid: FieldKey { "from_uid" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
