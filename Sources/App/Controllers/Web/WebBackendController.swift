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
  
  private func genPageMetadata(pageMeta: PageMetadata) -> AnyEncodable {
    let maxPage = pageMeta.pageCount
    let curPage = pageMeta.page

    var showMaxMore: Bool = true
    var showMinMore: Bool = true
    var showPages: [Int] = []
    
    if (maxPage <= 3) {
      showMaxMore = false
      showMinMore = false
      showPages = [Int](1...maxPage)
    } else {
      if(curPage < 3) {
        showMinMore = false
        showMaxMore = true
      }
      else if (curPage > maxPage - 3) {
        showMinMore = true
        showMaxMore = false
      }
      
      if (curPage == 1) {
        showPages = [curPage, curPage + 1, curPage + 2]
      } else if (curPage == maxPage) {
        showPages = [curPage - 2, curPage - 1, curPage]
      } else {
        showPages = [curPage - 1,curPage, curPage + 1]
      }
    }
    
    return [
      "maxPage": maxPage,
      "minPage": 1,
      "curPage": curPage,
      "showMinMore": showMinMore,
      "showMaxMore": showMaxMore,
      "showPages": showPages,
      "total": pageMeta.total,
      "page":pageMeta.page,
      "per": pageMeta.per,
      "perOptions": [
        ["value": "10", "label": "10条/页"],
        ["value": "20", "label": "20条/页"],
        ["value": "30", "label": "30条/页"],
        ["value": "50", "label": "50条/页"]
      ],
    ]
  }
  private func backendWrapper(_ req: Request, tabName: String, data: AnyEncodable? = nil, pageMeta:PageMetadata? = nil, dataIds:[UUID]? = nil) async throws -> [String: AnyEncodable?] {
    let user = try req.auth.require(User.self)
    let context: [String: AnyEncodable?] = [
      "tabName": .init(tabName),
      "user": .init(user.asPublic()),
      "data": data,
      "dataIds": .init(dataIds),
      "pageMeta": pageMeta != nil ? genPageMetadata(pageMeta: pageMeta!): nil,
      "menus": [
        ["href": "/web/backend/tagMgt", "label": "标签管理"],
        ["href": "/web/backend/categoryMgt", "label": "分类管理"],
        ["href": "/web/backend/postMgt", "label": "文章管理"],
        ["href": "/web/backend/linkMgt", "label": "友情链接"]
      ]
    ]
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
    let posts = try await req.repositories.post.page(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "文章管理",
                                           data: .init(posts),
                                           pageMeta: posts.metadata,
                                           dataIds: posts.items.map({$0.id!}))
    // 文章列表
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
    let _ = try await req.repositories.tag.add(inTag: inTag, ownerId: user.requireID())
    return req.redirect(to: "/web/backend/tagMgt");
  }
  
  private func updateTag(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateTag.validate(content: req)
    let inTag = try req.content.decode(InUpdateTag.self)
    let _ = try await req.repositories.tag.update(tag: inTag)
    return OutJson(success: OutOk())
  }
  
  private func deleteTags(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.tag.delete(tagIds: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 分类
  private func addCategory(_ req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    try InCategory.validate(content: req)
    let inCategory = try req.content.decode(InCategory.self)
    let _ = try await req.repositories.category.add(inCategory: inCategory, ownerId: user.requireID())
    return req.redirect(to: "/web/backend/categoryMgt");
  }
  
  private func updateCategory(_ req: Request) async throws -> OutJson<OutOk> {
    try InUpdateCategory.validate(content: req)
    let inCat = try req.content.decode(InUpdateCategory.self)
    let _ = try await req.repositories.category.update(category: inCat)
    return OutJson(success: OutOk())
  }
  
  private func deleteCategories(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.category.delete(categoryIds: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 文章
  private func addPost(_ req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    try InPost.validate(content: req)
    let inPost = try req.content.decode(InPost.self)
    let _ = try await req.repositories.post.add(inPost: inPost, ownerId: user.requireID())
    return req.redirect(to: "/web/backend/postMgt");
  }
  
  private func updatePost(_ req: Request) async throws -> OutJson<OutOk> {
    try InUpdatePost.validate(content: req)
    let inPost = try req.content.decode(InUpdatePost.self)
    let _ = try await req.repositories.post.update(post: inPost)
    return OutJson(success: OutOk())
  }
  
  private func deletePosts(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.post.delete(postIds: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 文章
  private func addLink(_ req: Request) async throws -> Response {
    // TODO: -
    let user = try req.auth.require(User.self)
    try InLink.validate(content: req)
    let inLink = try req.content.decode(InLink.self)
    let _ = try await req.repositories.link.add(inLink: inLink, ownerId: user.requireID())
    return req.redirect(to: "/web/backend/linkMgt");
  }
  
  private func updateLink(_ req: Request) async throws -> OutJson<OutOk> {
    try InUpdateLink.validate(content: req)
    let inLink = try req.content.decode(InUpdateLink.self)
    let _ = try await req.repositories.link.update(link: inLink)
    return OutJson(success: OutOk())
  }
  
  private func deleteLinks(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.link.delete(linkIds: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
}
