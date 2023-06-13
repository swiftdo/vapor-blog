//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Fluent
import Vapor

public struct UserRepositoryImpl: UserRepository {
    var req: Request
    
    public init(_ req: Request) {
        self.req = req
    }
    
    func getUser() async throws -> User {
        let payload = try req.auth.require(SessionToken.self)
        let user = try await User.find(payload.userId, on: req.db)
        guard let user = user else {
            throw ApiError(code: .userNotExist)
        }
        return user
    }
}
