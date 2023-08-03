//
//  File.swift
//  
//
//  Created by laijihua on 2023/8/3.
//

import Vapor
import Fluent

/// Category 增删改查
protocol CommentRepository: Repository {
  func add(param: InComment, fromUserId: User.IDValue) async throws -> Comment
  func all(topicId: UUID, topicType: Int) async throws -> [Comment.Public]
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws
}

extension RepositoryFactory {
    var comment: CommentRepository {
        guard let result = resolve(CommentRepository.self) as? CommentRepository else {
            fatalError("Comment repository is not configured")
        }
        return result
    }
}
