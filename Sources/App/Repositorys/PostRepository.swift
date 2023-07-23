//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor
import Fluent

/// Link增删改查
protocol PostRepository: Repository {
  func add(param: InPost, ownerId: User.IDValue) async throws -> Post
  func page(ownerId: User.IDValue) async throws -> Page<Post.Public>
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws
  func update(param: InUpdatePost, ownerId: User.IDValue) async throws
}

extension RepositoryFactory {
    var post: PostRepository {
        guard let result = resolve(PostRepository.self) as? PostRepository else {
            fatalError("Post repository is not configured")
        }
        return result
    }
}
