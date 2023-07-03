//
//  File.swift
//
//
//  Created by laijihua on 2023/6/14.
//

import Fluent
import SMTP
import Vapor

struct WebAuthController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let auth = routes.grouped("auth")
    auth.get("register", use: toRegister)
    auth.get("login", use: toLogin)

    // 接口
    auth.post("register", use: register)
    auth.post("register", "code", use: getRegisterCode)
    
    let credentialsRoute = auth.grouped(WebCredentialsAuthenticator())
    credentialsRoute.post("login", use: login)
    
    // 退出
    let tokenGroup = auth.grouped(WebSessionAuthenticator(), User.guardMiddleware())
    auth.get("logout", use: logout)
  }
}

extension WebAuthController {
  /// 登录页面
  private func toLogin(_ req: Request) async throws -> View {
    return try await req.view.render("auth/login", ["title": "博客"])
  }

  /// 注册页面
  private func toRegister(_ req: Request) async throws -> View {
    return try await req.view.render("auth/register")
  }

  private func register(_ req: Request) async throws -> Response {
    let _ = try await req.services.auth.register(req)
    return req.redirect(to: "/web/auth/login")
  }

  private func getRegisterCode(_ req: Request) async throws -> OutJson<OutOk> {
    return try await req.services.auth.getRegisterCode(req)
  }

  private func login(_ req: Request) async throws -> Response {
    guard let user = req.auth.get(User.self) else {
      throw Abort(.unauthorized)
    }
    // 添加这一步才会设置session
    req.session.authenticate(user)
    // 获取token，传给前端
    return req.redirect(to: "/")
  }
  
  private func logout(_ req: Request) async throws -> Response {
//    let user = try req.auth.require(User.self)
    req.auth.logout(User.self)
    req.session.unauthenticate(User.self)
    return req.redirect(to: "/")
  }
}
