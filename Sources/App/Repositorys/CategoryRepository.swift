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
  func allCategories(ownerId: User.IDValue) async throws -> [Category.Public]
  func add(inCategory: InCategory, ownerId: User.IDValue) async throws -> Category
  func page(ownerId: User.IDValue) async throws -> Page<Category.Public>
  func delete(categoryIds: InDeleteIds, ownerId: User.IDValue) async throws
  func update(category: InUpdateCategory) async throws
}

extension RepositoryFactory {
    var category: CategoryRepository {
        guard let result = resolve(CategoryRepository.self) as? CategoryRepository else {
            fatalError("Category repository is not configured")
        }
        return result
    }
}
