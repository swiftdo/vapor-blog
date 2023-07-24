//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/4.
//

import Fluent
import Vapor
import AnyCodable

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
    tokenGroup.post("tag", use: addTag)
    tokenGroup.post("tags", "delete", use: deleteTags)
    tokenGroup.post("tag", "update", use: updateTag)
    
    // 分类
    tokenGroup.post("category", use: addCategory)
    tokenGroup.post("categories", "delete", use: deleteCategories)
    tokenGroup.post("category", "update", use: updateCategory)
    
    // 文章
    tokenGroup.post("post", use: addPost)
    tokenGroup.post("posts", "delete", use: deletePosts)
    tokenGroup.post("post", "update", use: updatePost)
    
    // 链接
    tokenGroup.post("link", use: addLink)
    tokenGroup.post("links", "delete",use: deleteLinks)
    tokenGroup.post("link", "update", use: updateLink)
  }
}

extension WebBackendController {
  private func backendWrapper(_ req: Request, tabName: String, data: AnyEncodable? = nil, pageMeta:PageMetadata? = nil, dataIds:[UUID]? = nil, extra: [String: AnyEncodable?]? = nil) async throws -> [String: AnyEncodable?] {
    let user = try req.auth.require(User.self)
    var context: [String: AnyEncodable?] = [
      "tabName": .init(tabName),
      "user": .init(user.asPublic()),
      "data": data,
      "dataIds": .init(dataIds),
      "pageMeta": PageUtil.genPageMetadata(pageMeta: pageMeta),
      "menus": [
        ["href": "/web/backend/tagMgt", "label": "标签管理"],
        ["href": "/web/backend/categoryMgt", "label": "分类管理"],
        ["href": "/web/backend/postMgt", "label": "文章管理"],
        ["href": "/web/backend/linkMgt", "label": "友情链接"]
      ]
    ]
    if let extra = extra {
      context.merge(extra) { $1 }
    }
    return context
  }
  
  private func toIndex(_ req: Request) async throws -> View {
    return try await toTagMgt(req)
  }
  
  private func toTagMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let tags = try await req.repositories.tag.page(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "标签管理",
                                           data: .init(tags),
                                           pageMeta: tags.metadata,
                                           dataIds: tags.items.map({ $0.id! })
    )
    return try await req.view.render("backend/tagMgt", context)
  }
  
  private func toCategoryMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let categories = try await req.repositories.category.page(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "分类管理",
                                           data: .init(categories),
                                           pageMeta: categories.metadata,
                                           dataIds: categories.items.map({$0.id!}))
    return try await req.view.render("backend/categoryMgt", context)
  }
  
  private func toPostMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let userId = try user.requireID()
    let posts = try await req.repositories.post.page(ownerId: userId)
    let tags = try await req.repositories.tag.all(ownerId: userId)
    let categories = try await req.repositories.category.all(ownerId: userId)
    let context = try await backendWrapper(req,
                                           tabName: "文章管理",
                                           data: .init(posts),
                                           pageMeta: posts.metadata,
                                           dataIds: posts.items.map({$0.id!}),
                                           extra: [
                                            "optionTags": .init(tags),
                                            "optionCategories": .init(categories)
                                           ])
    return try await req.view.render("backend/postMgt", context)
  }

  private func toLinkMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let links = try await req.repositories.link.page(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "友情链接",
                                           data: .init(links),
                                           pageMeta: links.metadata,
                                           dataIds: links.items.map({$0.id!}))
    return try await req.view.render("backend/linkMgt", context)
  }
  
  /// tag 管理
  private func addTag(_ req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    try InTag.validate(content: req)
    let inTag = try req.content.decode(InTag.self)
    let _ = try await req.repositories.tag.add(param: inTag, ownerId: user.requireID())
    return req.redirect(to: "/web/backend/tagMgt");
  }
  
  private func updateTag(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateTag.validate(content: req)
    let inTag = try req.content.decode(InUpdateTag.self)
    let _ = try await req.repositories.tag.update(param: inTag, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func deleteTags(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.tag.delete(ids: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 分类
  private func addCategory(_ req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    try InCategory.validate(content: req)
    let inCategory = try req.content.decode(InCategory.self)
    let _ = try await req.repositories.category.add(param: inCategory, ownerId: user.requireID())
    return req.redirect(to: "/web/backend/categoryMgt");
  }
  
  private func updateCategory(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateCategory.validate(content: req)
    let inCat = try req.content.decode(InUpdateCategory.self)
    let _ = try await req.repositories.category.update(param: inCat, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func deleteCategories(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.category.delete(ids: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 文章
  private func addPost(_ req: Request) async throws -> OutJson<OutOk>  {
    let user = try req.auth.require(User.self)
    try InPost.validate(content: req)
    let inPost = try req.content.decode(InPost.self)
    let _ = try await req.repositories.post.add(param: inPost, ownerId: user.requireID())
    return OutJson(success: OutOk());
  }
  
  private func updatePost(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdatePost.validate(content: req)
    let inPost = try req.content.decode(InUpdatePost.self)
    let _ = try await req.repositories.post.update(param: inPost, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func deletePosts(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.post.delete(ids: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 文章
  private func addLink(_ req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    try InLink.validate(content: req)
    let inLink = try req.content.decode(InLink.self)
    let _ = try await req.repositories.link.add(param: inLink, ownerId: user.requireID())
    return req.redirect(to: "/web/backend/linkMgt");
  }
  
  private func updateLink(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateLink.validate(content: req)
    let inLink = try req.content.decode(InUpdateLink.self)
    let _ = try await req.repositories.link.update(param: inLink, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func deleteLinks(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.link.delete(ids: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
}
