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
    auth.get("register", use: register)
    auth.get("login", use: login)
  }
}

extension WebAuthController {

  /// 登录
  private func login(_ req: Request) async throws -> View {
    return try await req.view.render("auth/login", ["title": "博客"])
  }

  /// 注册
  private func register(_ req: Request) async throws -> View {
    return try await req.view.render("auth/register")
  }
}
