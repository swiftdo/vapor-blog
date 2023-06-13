//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Vapor

extension User {
    struct Public: Out {
        let id: UUID?
        let name: String
        let email: String
        let isEmailVerified: Bool
        let status: Int
        let isAdmin: Bool
    }

    func asPublic() -> Public {
        return Public(
            id: self.id,
            name: self.name,
            email: self.email,
            isEmailVerified: self.isEmailVerified,
            status: self.status,
            isAdmin: self.isAdmin
        )
    }
}

