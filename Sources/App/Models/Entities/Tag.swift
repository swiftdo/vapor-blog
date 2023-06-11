//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/9.
//


import Fluent
import Vapor

final class Tag: Model {
    
    static let schema = "blog_tag"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.name)
    var name: String
    
    @Field(key: FieldKeys.status)
    var status: Int // 正常(1)|删除(0),
        
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

extension Tag {
    struct FieldKeys {
        static var name: FieldKey { "name" }
        static var status: FieldKey { "status" }
        static var ownerId: FieldKey { "owner_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}

