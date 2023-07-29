//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor
import Fluent

/// tag 增删改查
protocol RoleRepository: Repository {
  func all(ownerId: User.IDValue?) async throws -> [Role.Public]
  func add(param: InRole, ownerId: User.IDValue) async throws -> Role
  func page(ownerId: User.IDValue?) async throws -> Page<Role.Public>
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws
  func update(param: InUpdateRole, ownerId: User.IDValue) async throws
}

extension RepositoryFactory {
    var role: RoleRepository {
        guard let result = resolve(RoleRepository.self) as? RoleRepository else {
            fatalError("Role repository is not configured")
        }
        return result
    }
}

