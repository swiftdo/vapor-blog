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
    routes.get("register", use: toRegister)
    routes.get("login", use: toLogin)

    // 接口
    routes.post("register", use: register)
    routes.post("register", "code", use: getRegisterCode)
    
    let credentialsRoute = routes.grouped(WebCredentialsAuthenticator())
    credentialsRoute.post("login", use: login)
    
    // 退出
    let tokenGroup = routes.grouped(WebSessionAuthenticator(), User.guardMiddleware())
    tokenGroup.get("logout", use: logout)
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
    let _ = try await req.services.auth.register()
    return req.redirect(to: "/web/auth/login")
  }

  private func getRegisterCode(_ req: Request) async throws -> OutJson<OutOk> {
    return try await req.services.auth.getRegisterCode()
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
