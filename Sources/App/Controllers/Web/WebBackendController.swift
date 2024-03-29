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
    
    // TODO: 超级管理员具有的初始化配置
    routes.grouped(WebSessionAuthenticator()).get("config", use: configBackend)
   
    // 标签
    tokenGroup.get("tagMgt", use: toTagMgt)
    tokenGroup.post("tag", use: addTag)
    tokenGroup.post("tags", "delete", use: deleteTags)
    tokenGroup.post("tag", "update", use: updateTag)
    
    // 分类
    tokenGroup.get("categoryMgt", use: toCategoryMgt)
    tokenGroup.post("category", use: addCategory)
    tokenGroup.post("categories", "delete", use: deleteCategories)
    tokenGroup.post("category", "update", use: updateCategory)
    
    // 文章
    tokenGroup.get("postMgt", use: toPostMgt)
    tokenGroup.post("post", use: addPost)
    tokenGroup.post("posts", "delete", use: deletePosts)
    tokenGroup.post("post", "update", use: updatePost)
    
    // 链接
    tokenGroup.get("linkMgt", use: toLinkMgt)
    tokenGroup.post("link", use: addLink)
    tokenGroup.post("links", "delete",use: deleteLinks)
    tokenGroup.post("link", "update", use: updateLink)
    
    // 用户管理
    tokenGroup.get("userMgt", use: toUserMgt)
    tokenGroup.post("user", "update", use: updateUser)
    
    // 角色管理
    tokenGroup.get("roleMgt", use: toRoleMgt)
    tokenGroup.post("role", use: addRole)
    tokenGroup.post("roles", "delete",use: deleteRoles)
    tokenGroup.post("role", "update", use: updateRole)
    // 权限管理
    tokenGroup.get("permissionMgt", use: toPermissionMgt)
    tokenGroup.post("permission", use: addPermission)
    tokenGroup.post("permissions", "delete",use: deletePermissions)
    tokenGroup.post("permission", "update", use: updatePermission)
    // 菜单管理
    tokenGroup.get("menuMgt", use: toMenuMgt)
    tokenGroup.post("menu", use: addMenu)
    tokenGroup.post("menus", "delete",use: deleteMenus)
    tokenGroup.post("menu", "update", use: updateMenu)
  }
}

extension WebBackendController {
  private func backendWrapper(_ req: Request, tabName: String, data: AnyEncodable? = nil, pageMeta:PageMetadata? = nil, dataIds:[UUID]? = nil, extra: [String: AnyEncodable?]? = nil) async throws -> [String: AnyEncodable?] {
    let user = try req.auth.require(User.self)
    let menus = try await req.services.backend.menus(user: user)
    var context: [String: AnyEncodable?] = [
      "tabName": .init(tabName),
      "user": .init(user.asPublic()),
      "data": data,
      "dataIds": .init(dataIds),
      "pageMeta": PageUtil.genPageMetadata(pageMeta: pageMeta),
      "menus": .init(menus)
    ]
    if let extra = extra {
      context.merge(extra) { $1 }
    }
    return context
  }
  
  private func toIndex(_ req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    let menus = try await req.services.backend.menus(user: user)
    guard let menu = menus.first else {
      throw ApiError(code: .menuNotConfig)
    }
    return req.redirect(to: menu.url)
  }

  /// tag 管理
  private func toTagMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let items = try await req.repositories.tag.page(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "标签管理",
                                           data: .init(items),
                                           pageMeta: items.metadata,
                                           dataIds: items.items.map({ $0.id! })
    )
    return try await req.view.render("backend/tagMgt", context)
  }
  
  private func addTag(_ req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    try InTag.validate(content: req)
    let param = try req.content.decode(InTag.self)
    let _ = try await req.repositories.tag.add(param: param, ownerId: user.requireID())
    return req.redirect(to: "/web/backend/tagMgt");
  }
  
  private func updateTag(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateTag.validate(content: req)
    let param = try req.content.decode(InUpdateTag.self)
    let _ = try await req.repositories.tag.update(param: param, ownerId: user.requireID())
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
  private func toCategoryMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let items = try await req.repositories.category.page(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "分类管理",
                                           data: .init(items),
                                           pageMeta: items.metadata,
                                           dataIds: items.items.map({$0.id!}))
    return try await req.view.render("backend/categoryMgt", context)
  }
  
  private func addCategory(_ req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    try InCategory.validate(content: req)
    let param = try req.content.decode(InCategory.self)
    let _ = try await req.repositories.category.add(param: param, ownerId: user.requireID())
    return req.redirect(to: "/web/backend/categoryMgt");
  }
  
  private func updateCategory(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateCategory.validate(content: req)
    let param = try req.content.decode(InUpdateCategory.self)
    let _ = try await req.repositories.category.update(param: param, ownerId: user.requireID())
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
  
  private func addPost(_ req: Request) async throws -> OutJson<OutOk>  {
    let user = try req.auth.require(User.self)
    try InPost.validate(content: req)
    let param = try req.content.decode(InPost.self)
    let _ = try await req.repositories.post.add(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk());
  }
  
  private func updatePost(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdatePost.validate(content: req)
    let param = try req.content.decode(InUpdatePost.self)
    let _ = try await req.repositories.post.update(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func deletePosts(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.post.delete(ids: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // Mark: 链接
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
  private func addLink(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InLink.validate(content: req)
    let inLink = try req.content.decode(InLink.self)
    let _ = try await req.repositories.link.add(param: inLink, ownerId: user.requireID())
    return OutJson(success: OutOk());
  }
  
  private func updateLink(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateLink.validate(content: req)
    let param = try req.content.decode(InUpdateLink.self)
    let _ = try await req.repositories.link.update(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func deleteLinks(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.link.delete(ids: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 角色
  private func toRoleMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let items = try await req.repositories.role.page(ownerId: user.requireID())
    let permissions = try await req.repositories.permission.all(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "角色管理",
                                           data: .init(items),
                                           pageMeta: items.metadata,
                                           dataIds: items.items.map({$0.id!}),
                                           extra: ["optionPermissions": .init(permissions)])
    return try await req.view.render("backend/roleMgt", context)
  }
  private func addRole(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InRole.validate(content: req)
    let param = try req.content.decode(InRole.self)
    let _ = try await req.repositories.role.add(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk());
  }
  
  private func updateRole(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateRole.validate(content: req)
    let param = try req.content.decode(InUpdateRole.self)
    let _ = try await req.repositories.role.update(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func deleteRoles(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.role.delete(ids: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 权限
  private func toPermissionMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let items = try await req.repositories.permission.page(ownerId: user.requireID())
    let menus = try await req.repositories.menu.all(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "权限管理",
                                           data: .init(items),
                                           pageMeta: items.metadata,
                                           dataIds: items.items.map({$0.id!}),
                                           extra: ["optionMenus": .init(menus)]
    )
    return try await req.view.render("backend/permissionMgt", context)
  }
  
  private func addPermission(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InPermission.validate(content: req)
    let param = try req.content.decode(InPermission.self)
    let _ = try await req.repositories.permission.add(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk());
  }
  
  private func updatePermission(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdatePermission.validate(content: req)
    let param = try req.content.decode(InUpdatePermission.self)
    let _ = try await req.repositories.permission.update(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func deletePermissions(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.permission.delete(ids: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 菜单
  private func toMenuMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let items = try await req.repositories.menu.page(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "菜单管理",
                                           data: .init(items),
                                           pageMeta: items.metadata,
                                           dataIds: items.items.map({$0.id!}))
    return try await req.view.render("backend/menuMgt", context)
  }
  private func addMenu(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InMenu.validate(content: req)
    let param = try req.content.decode(InMenu.self)
    let _ = try await req.repositories.menu.add(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk());
  }
  
  private func updateMenu(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateMenu.validate(content: req)
    let param = try req.content.decode(InUpdateMenu.self)
    let _ = try await req.repositories.menu.update(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func deleteMenus(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InDeleteIds.validate(content: req)
    let delIds = try req.content.decode(InDeleteIds.self)
    try await req.repositories.menu.delete(ids: delIds, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 用户管理
  private func toUserMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let items = try await req.repositories.user.page(ownerId: user.requireID())
    // 获取角色列表
    let roles = try await req.repositories.role.all(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "用户管理",
                                           data: .init(items),
                                           pageMeta: items.metadata,
                                           dataIds: items.items.map({$0.id!}),
                                           extra: ["optionRoles": .init(roles)])
    return try await req.view.render("backend/userMgt", context)
  }

  private func updateUser(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InUpdateUser.validate(content: req)
    let param = try req.content.decode(InUpdateUser.self)
    let _ = try await req.repositories.user.update(param: param, ownerId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  private func configBackend(_ req: Request) async throws -> OutJson<OutOk> {
    let user = req.auth.get(User.self)
    let roles = try await req.repositories.role.all(ownerId: user?.id)
    if !roles.isEmpty {
      throw ApiError(code: .configAlready)
    }
    let admin = try await req.services.auth.registerSystemAdmin()
    let userRole = try await req.repositories.role.add(param: InRole(name: Constants.userRoleName), ownerId: admin.requireID())
    let adminRole = try  await req.repositories.role.add(param: InRole(name: Constants.userRoleAdmin), ownerId: admin.requireID())
    try await admin.$roles.attach([userRole, adminRole], on: req.db)
    
    // 权限初始化
    let inPerm_view_user_mgt = InPermission(name: "用户管理查看", code: "view_user_mgt")
    let inPerm_edit_user_mgt = InPermission(name: "用户管理修改", code: "edit_user_mgt")
    let inPerm_add_permission_mgt = InPermission(name: "权限管理添加", code: "add_permission_mgt")
    let inPerm_delete_permission_mgt = InPermission(name: "权限管理删除", code: "delete_permission_mgt")
    let inPerm_edit_permission_mgt = InPermission(name: "权限管理编辑", code: "edit_permission_mgt")
    let inPerm_view_link_mgt = InPermission(name: "友情链接管理查看", code: "view_link_mgt")
    let inPerm_view_post_mgt = InPermission(name: "文章管理查看", code: "view_post_mgt")
    let inPerm_view_category_mgt = InPermission(name: "分类管理查看", code: "view_category_mgt")
    let inPerm_view_tag_mgt = InPermission(name: "标签管理查看", code: "view_tag_mgt")
    let inPerm_view_menu_mgt = InPermission(name: "菜单管理查看", code: "view_menu_mgt")
    let inPerm_view_role_mgt = InPermission(name: "角色管理查看", code: "view_role_mgt")
    let inPerm_view_permission_mgt = InPermission(name: "权限管理查看", code: "view_permission_mgt")
    
    // 权限初始化
    let perm_view_user_mgt = try await req.repositories.permission.add(param: inPerm_view_user_mgt, ownerId: admin.requireID())
    let perm_edit_user_mgt = try await req.repositories.permission.add(param: inPerm_edit_user_mgt, ownerId: admin.requireID())
    let perm_add_permission_mgt = try await req.repositories.permission.add(param: inPerm_add_permission_mgt, ownerId: admin.requireID())
    let perm_delete_permission_mgt = try await req.repositories.permission.add(param: inPerm_delete_permission_mgt, ownerId: admin.requireID())
    let perm_edit_permission_mgt = try await req.repositories.permission.add(param: inPerm_edit_permission_mgt, ownerId: admin.requireID())
    let perm_view_link_mgt = try await req.repositories.permission.add(param: inPerm_view_link_mgt, ownerId: admin.requireID())
    let perm_view_post_mgt = try await req.repositories.permission.add(param: inPerm_view_post_mgt, ownerId: admin.requireID())
    let perm_view_category_mgt = try await req.repositories.permission.add(param: inPerm_view_category_mgt, ownerId: admin.requireID())
    let perm_view_tag_mgt = try await req.repositories.permission.add(param: inPerm_view_tag_mgt, ownerId: admin.requireID())
    let perm_view_menu_mgt = try await req.repositories.permission.add(param: inPerm_view_menu_mgt, ownerId: admin.requireID())
    let perm_view_role_mgt = try await req.repositories.permission.add(param: inPerm_view_role_mgt, ownerId: admin.requireID())
    let perm_view_permission_mgt = try await req.repositories.permission.add(param: inPerm_view_permission_mgt, ownerId: admin.requireID())
    
    // 菜单初始化
    let inMenu_userMgt = InMenu(name: "用户管理", weight: 100, url: "/web/backend/userMgt")
    let inMenu_roleMgt = InMenu(name: "角色管理", weight: 98, url: "/web/backend/roleMgt")
    let inMenu_permissionMgt = InMenu(name: "权限管理", weight: 97, url: "/web/backend/permissionMgt")
    let inMenu_menuMgt = InMenu(name: "菜单管理", weight: 96, url: "/web/backend/menuMgt")
    let inMenu_tagMgt = InMenu(name: "标签管理", weight: 95, url: "/web/backend/tagMgt")
    let inMenu_categoryMgt = InMenu(name: "分类管理", weight: 94, url: "/web/backend/categoryMgt")
    let inMenu_postMgt = InMenu(name: "文章管理", weight: 92, url: "/web/backend/postMgt")
    let inMenu_linkMgt = InMenu(name: "友情链接", weight: 92, url: "/web/backend/linkMgt")
    
    let menu_userMgt = try await req.repositories.menu.add(param: inMenu_userMgt, ownerId: admin.requireID())
    let menu_roleMgt = try await req.repositories.menu.add(param: inMenu_roleMgt, ownerId: admin.requireID())
    let menu_permissionMgt = try await req.repositories.menu.add(param: inMenu_permissionMgt, ownerId: admin.requireID())
    let menu_menuMgt = try await req.repositories.menu.add(param: inMenu_menuMgt, ownerId: admin.requireID())
    let menu_tagMgt = try await req.repositories.menu.add(param: inMenu_tagMgt, ownerId: admin.requireID())
    let menu_categoryMgt = try await req.repositories.menu.add(param: inMenu_categoryMgt, ownerId: admin.requireID())
    let menu_postMgt = try await req.repositories.menu.add(param: inMenu_postMgt, ownerId: admin.requireID())
    let menu_linkMgt = try await req.repositories.menu.add(param: inMenu_linkMgt, ownerId: admin.requireID())
    
    try await menu_userMgt.$permissions.attach(perm_view_user_mgt, on: req.db)
    try await menu_roleMgt.$permissions.attach(perm_view_role_mgt, on: req.db)
    try await menu_permissionMgt.$permissions.attach(perm_view_permission_mgt, on: req.db)
    try await menu_menuMgt.$permissions.attach(perm_view_menu_mgt, on: req.db)
    try await menu_tagMgt.$permissions.attach(perm_view_tag_mgt, on: req.db)
    try await menu_categoryMgt.$permissions.attach(perm_view_category_mgt, on: req.db)
    try await menu_postMgt.$permissions.attach(perm_view_post_mgt, on: req.db)
    try await menu_linkMgt.$permissions.attach(perm_view_link_mgt, on: req.db)
    
    // 角色绑定权限
    try await adminRole.$permissions.attach([
      perm_view_user_mgt,
      perm_edit_user_mgt,
      perm_add_permission_mgt,
      perm_delete_permission_mgt,
      perm_edit_permission_mgt,
      perm_view_link_mgt,
      perm_view_post_mgt,
      perm_view_category_mgt,
      perm_view_tag_mgt,
      perm_view_menu_mgt,
      perm_view_role_mgt,
      perm_view_permission_mgt
    ], on: req.db)
    
    try await userRole.$permissions.attach([
      perm_view_post_mgt
    ], on: req.db)
    return OutJson(success: OutOk())
  }
}
