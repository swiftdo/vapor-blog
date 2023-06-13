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
}

extension RepositoryFactory {
    var user: UserRepository {
        guard let result = resolve(UserRepository.self) as? UserRepository else {
            fatalError("User repository is not configured")
        }
        return result
    }
}
