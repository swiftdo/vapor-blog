//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/23.
//
import Foundation

protocol InviteRepository: Repository {
    func generateInviteCode() async throws -> String
}

extension RepositoryFactory {
    var invite: InviteRepository {
        guard let result = resolve(InviteRepository.self) as? InviteRepository else {
            fatalError("Invite repository is not configured")
        }
        return result
    }
}

