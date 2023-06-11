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
    
    @OptionalField(key: FieldKeys.website)
    var website: String?
    
    @Field(key: FieldKeys.email)
    var email: String
    
    @Parent(key: FieldKeys.targetId)
    var target: Post
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
        var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() { }

    init(id: UUID? = nil) throws {
        self.id = id
        
    }
}

extension Comment {
    struct FieldKeys {
        static var status: FieldKey { "status" }
        static var content: FieldKey { "content" }
        static var website: FieldKey { "website" }
        static var email: FieldKey { "email" }
        static var targetId: FieldKey { "target_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
