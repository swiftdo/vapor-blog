//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/9.
//

import Fluent
import Vapor



final class Category: Model {
    
    static let schema = "blog_category"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.name)
    var name: String
    
    @Field(key: FieldKeys.status)
    var status: Int // 正常|删除
    
    @Field(key: FieldKeys.isNav)
    var isNav: Bool
    
    @Parent(key: FieldKeys.ownerId)
    var owner: User
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
        var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    init() {}
    
    init(id: UUID? = nil, name: String, ownerId: User.IDValue, status: Int = 1) {
        self.id = id
        self.name = name
        self.$owner.id = ownerId
        self.status = status
    }
}

extension Category {
    struct FieldKeys {
        static var name: FieldKey { "name" }
        static var status: FieldKey { "status" }
        static var isNav: FieldKey { "is_nav" }
        static var ownerId: FieldKey { "owner_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}
