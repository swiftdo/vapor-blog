//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Fluent
import Vapor

protocol UserRepository: Repository {
  func getUser() async throws -> User
  // 用户列表
  func page(ownerId: User.IDValue?) async throws -> Page<User.Public>
  // 用户更新
  func update(param: InUpdateUser, ownerId: User.IDValue?) async throws  
}

extension RepositoryFactory {
    var user: UserRepository {
        guard let result = resolve(UserRepository.self) as? UserRepository else {
            fatalError("User repository is not configured")
        }
        return result
    }
}
