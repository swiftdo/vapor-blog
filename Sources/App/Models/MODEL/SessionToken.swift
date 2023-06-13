//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/12.
//

import JWT
import Vapor

struct SessionToken: Content, Authenticatable, JWTPayload {

    // Constants
    var expirationTime: TimeInterval = 60 * 60

    // Token Data
    var expiration: ExpirationClaim
    var userId: UUID

    init(userId: UUID) {
        self.userId = userId
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    init(user: User) throws {
        self.userId = try user.requireID()
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

