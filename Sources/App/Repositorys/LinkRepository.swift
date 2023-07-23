//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/20.
//

import Vapor
import Fluent

/// Link增删改查
protocol LinkRepository: Repository {
  func add(in: InLink, ownerId: User.IDValue) async throws -> Link
  func page(ownerId: User.IDValue) async throws -> Page<Link.Public>
  func delete(ids: InDeleteIds, ownerId: User.IDValue) async throws
  func update(in: InUpdateLink, ownerId: User.IDValue) async throws
}

extension RepositoryFactory {
    var link: LinkRepository {
        guard let result = resolve(LinkRepository.self) as? LinkRepository else {
            fatalError("Link repository is not configured")
        }
        return result
    }
}
