//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/3.
//

import Foundation
import Vapor
import Fluent

/// Category 增删改查
protocol ReplyRepository: Repository {
  func add(param: InReply, fromUserId: User.IDValue) async throws -> Reply
  func all(commentId: Comment.IDValue) async throws -> [Reply.Public]
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws
}

extension RepositoryFactory {
    var reply: ReplyRepository {
        guard let result = resolve(ReplyRepository.self) as? ReplyRepository else {
            fatalError("Reply repository is not configured")
        }
        return result
    }
}
