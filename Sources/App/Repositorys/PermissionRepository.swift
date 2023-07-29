//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor
import Fluent

/// tag 增删改查
protocol PermissionRepository: Repository {
  func all(ownerId: User.IDValue?) async throws -> [Permission.Public]
  func add(param: InPermission, ownerId: User.IDValue) async throws -> Permission
  func page(ownerId: User.IDValue?) async throws -> Page<Permission.Public>
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws
  func update(param: InUpdatePermission, ownerId: User.IDValue) async throws
}

extension RepositoryFactory {
    var permission: PermissionRepository {
        guard let result = resolve(PermissionRepository.self) as? PermissionRepository else {
            fatalError("Permission repository is not configured")
        }
        return result
    }
}

