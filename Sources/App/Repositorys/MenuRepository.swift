//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/28.
//

import Vapor
import Fluent

/// Menu增删改查
protocol MenuRepository: Repository {
  func all(permissions: [Permission]) async throws -> [Menu.Public]
  func all(ownerId: User.IDValue?) async throws -> [Menu.Public]
  func add(param: InMenu, ownerId: User.IDValue) async throws -> Menu
  func page(ownerId: User.IDValue?) async throws -> Page<Menu.Public>
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws
  func update(param: InUpdateMenu, ownerId: User.IDValue) async throws
}

extension RepositoryFactory {
    var menu: MenuRepository {
        guard let result = resolve(MenuRepository.self) as? MenuRepository else {
            fatalError("Menu repository is not configured")
        }
        return result
    }
}

