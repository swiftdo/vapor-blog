//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/9.
//

import Fluent
import Vapor

final class Post: Model {
    static let schema = "blog_post"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.title)
    var title: String
    
    @Field(key: FieldKeys.desc)
    var desc: String
    
    @Field(key: FieldKeys.content)
    var content: String
    
    @Field(key: FieldKeys.status)
    var status: Int // 正常(1)|删除(0)|草稿(2),
        
    @Parent(key: FieldKeys.ownerId)
    var owner: User
    
    @Parent(key: FieldKeys.categoryId)
    var category: Category
    
    @Siblings(through: PostTag.self, from: \.$post, to: \.$tag)
    public var tags: [Tag]
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    
    init() {}
    
    init(id: UUID? = nil, title: String, ownerId: User.IDValue, status: Int = 1, content: String, desc: String, categoryId: Category.IDValue) {
        self.id = id
        self.title = title
        self.desc = desc
        self.content = content
        self.status = status
        self.$category.id = categoryId
        self.$owner.id = ownerId
    }
}

extension Post {
    struct FieldKeys {
        static var title: FieldKey { "title" }
        static var desc: FieldKey { "desc" }
        static var content: FieldKey { "content" }
        static var status: FieldKey { "status" }
        static var ownerId: FieldKey { "owner_id" }
        static var categoryId: FieldKey { "category_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}


