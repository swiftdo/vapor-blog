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
  
  func page(ownerId: User.IDValue?) async throws -> Page<User.Public> {
    return try await User.query(on: req.db)
      .with(\.$roles)
      .filter(\.$status == 1)
      .sort(\.$createdAt, .descending)
      .paginate(for:req)
      .map({$0.asPublic()})
  }
  
  func update(param: InUpdateUser, ownerId: User.IDValue?) async throws {
    try await req.db.transaction { db in
//      try await User.query(on: db)
//        .set(\.$title, to: param.title)
//        .filter(\.$id == param.id)
//        .update()
      guard let ret = try await User.query(on: db)
        .with(\.$roles)
        .filter(\.$id == param.id)
        .first()
      else {
        throw ApiError(code: .userNotExist)
      }
      
      try await ret.$roles.detachAll(on: db)
      let roles = try await Role.query(on: db).filter(\.$id ~~ param.roleIds).all()
      try await ret.$roles.attach(roles, on: db)
    }
  }
}
