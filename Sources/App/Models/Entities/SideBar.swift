//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/9.
//

import Fluent
import Vapor

final class SideBar: Model {
    
    static let schema = "blog_sidebar"

    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.title)
    var title: String
    
    @Field(key: FieldKeys.displayType)
    var displayType: Int // HTML(1)|最新文章(2)|最热文章(3)|最近评论(4)
    
    @Field(key: FieldKeys.status)
    var status: Int // 展示(1)|隐藏(0)
    
    @Field(key: FieldKeys.content)
    var content: String
    
    @Parent(key: FieldKeys.ownerId)
    var owner: User
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
        var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() { }

    init(id: UUID? = nil) throws {
        self.id = id
        
    }
}

extension SideBar {
    struct FieldKeys {
        static var status: FieldKey { "status" }
        static var title: FieldKey { "title" }
        static var displayType: FieldKey { "display_type" }
        static var content: FieldKey { "content" }
        static var ownerId: FieldKey { "owner_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
