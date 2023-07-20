//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/9.
//

import Fluent
import Vapor

final class Link: Model {
    
    static let schema = "blog_link"

    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.title)
    var title: String
    
    @Field(key: FieldKeys.href)
    var href: String
    
    @Field(key: FieldKeys.status)
    var status: Int // 正常|删除
    
    @Field(key: FieldKeys.weight)
    var weight: Int
    
    @Parent(key: FieldKeys.ownerId)
    var owner: User
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
        var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() { }

  init(id: UUID? = nil, title: String, href: String, status: Int = 1, weight: Int = 1, ownerId: User.IDValue) {
    self.id = id
    self.title = title
    self.href = href
    self.status = status
    self.weight = weight
    self.$owner.id = ownerId
  }
}

extension Link {
    struct FieldKeys {
        static var status: FieldKey { "status" }
        static var title: FieldKey { "title" }
        static var href: FieldKey { "href" }
        static var weight: FieldKey { "weight" }
        static var ownerId: FieldKey { "owner_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
