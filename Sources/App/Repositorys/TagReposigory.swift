//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/9.
//

import Vapor
import Fluent

/// tag 增删改查
protocol TagRepository: Repository {
  func all(ownerId: User.IDValue?) async throws -> [Tag.Public]
  func add(param: InTag, ownerId: User.IDValue) async throws -> Tag
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws
  func page(ownerId: User.IDValue?) async throws -> Page<Tag.Public>
  func update(param: InUpdateTag, ownerId: User.IDValue) async throws
  func hot(limit: Int) async throws -> [Tag.Public]
}

extension RepositoryFactory {
    var tag: TagRepository {
        guard let result = resolve(TagRepository.self) as? TagRepository else {
            fatalError("Tag repository is not configured")
        }
        return result
    }
}

