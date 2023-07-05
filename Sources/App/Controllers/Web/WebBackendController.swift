//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/4.
//

import Fluent
import Vapor

struct WebBackendController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    // 必须要登录
    let tokenGroup = routes.grouped(WebSessionAuthenticator(), User.guardMiddleware())
    tokenGroup.get(use: toIndex)
    tokenGroup.get("tagMgt", use: toTagMgt)
    tokenGroup.get("categoryMgt", use: toCategoryMgt)
    tokenGroup.get("postMgt", use: toPostMgt)
    tokenGroup.get("linkMgt", use: toLinkMgt)
    
    // 标签
    
    
    // 分类
    
    // 文章
    
    // 链接
    
    
  }
}

extension WebBackendController {
  private func toIndex(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let outUser = user.asPublic()
      // 获取到当前用户信息
    return try await req.view.render("backend/index", ["user": outUser])
  }
  
  private func toTagMgt(_ req: Request) async throws -> View {
    return try await req.view.render("backend/tagMgt")
  }
  
  private func toCategoryMgt(_ req: Request) async throws -> View {
    return try await req.view.render("backend/categoryMgt")
  }
  
  private func toPostMgt(_ req: Request) async throws -> View {
    return try await req.view.render("backend/postMgt")
  }

  private func toLinkMgt(_ req: Request) async throws -> View {
    return try await req.view.render("backend/toLinkMgt")
  }
  
}
