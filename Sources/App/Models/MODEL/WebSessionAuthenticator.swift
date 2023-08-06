//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/3.
//

import Vapor
// session 登录和验证

// 可认证的会话
extension User: SessionAuthenticatable {
  typealias SessionID = User.IDValue
  var sessionID: SessionID { self.id! }
}

// 会话认证器
struct WebSessionAuthenticator: AsyncSessionAuthenticator {  
  typealias User = App.User
  
  func authenticate(sessionID: User.SessionID, for request: Request) async throws {
    let user = try await User.find(sessionID, on: request.db)
    if let user = user {
      request.auth.login(user)
    }
  }
}

// 登录
struct WebCredentialsAuthenticator: AsyncCredentialsAuthenticator {
  
  typealias Credentials = InLogin
  
  func authenticate(credentials: Credentials, for request: Request) async throws {
    let  (isValid, userAuth) = try await request.services.auth.isValidPwd(email: credentials.email, pwd: credentials.password)
    if isValid {
      let user = try await userAuth.$user.get(on: request.db)
      request.auth.login(user)
    }
  }
}

