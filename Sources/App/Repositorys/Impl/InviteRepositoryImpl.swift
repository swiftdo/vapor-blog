//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/23.
//


import Vapor
import Fluent

struct InviteRepositoryImpl: InviteRepository {
    
    var req: Request
    
    init(_ req: Request) {
        self.req = req
    }
    
    func generateInviteCode() async throws -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var inviteCode = String((0..<6).map{ _ in letters.randomElement()! })
        
        while try await checkIfExists(inviteCode: inviteCode) {
            inviteCode = String((0..<6).map{ _ in letters.randomElement()! })
        }
        
        let invite = Invite(code: inviteCode)
        try await invite.save(on: req.db)
        return inviteCode
    }
    
    private func checkIfExists(inviteCode: String) async throws -> Bool {
        return try await Invite.query(on: req.db).filter(\.$code == inviteCode).first().map({_ in true }) ?? false
    }
}
