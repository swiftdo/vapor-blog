//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor
import Fluent

/// Category 增删改查
protocol CategoryRepository: Repository {
  func all(ownerId: User.IDValue) async throws -> [Category.Public]
  func add(param: InCategory, ownerId: User.IDValue) async throws -> Category
  func page(ownerId: User.IDValue) async throws -> Page<Category.Public>
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws
  func update(param: InUpdateCategory, ownerId: User.IDValue) async throws
}

extension RepositoryFactory {
    var category: CategoryRepository {
        guard let result = resolve(CategoryRepository.self) as? CategoryRepository else {
            fatalError("Category repository is not configured")
        }
        return result
    }
}
