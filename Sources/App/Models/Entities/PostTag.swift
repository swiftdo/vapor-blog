//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/11.
//

import Fluent
import Vapor

final class PostTag: Model {
    static let schema = "blog_planet_tag"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.postId)
    var post: Post

    @Parent(key: FieldKeys.tagId)
    var tag: Tag
    
    init() { }

    init(id: UUID? = nil, post: Post, tag: Tag) throws {
        self.id = id
        self.$post.id = try post.requireID()
        self.$tag.id = try tag.requireID()
    }
}

extension PostTag {
    struct FieldKeys {
        static var postId: FieldKey { "post_id" }
        static var tagId: FieldKey { "tag_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}

