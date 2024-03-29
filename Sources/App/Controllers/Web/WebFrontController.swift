
import Fluent
import Vapor
import AnyCodable

struct WebFrontController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    
    let tokenGroup = routes.grouped(WebSessionAuthenticator())
    tokenGroup.get(use: toIndex)
    tokenGroup.get("index", use: toIndex)
    tokenGroup.get("detail", use: toDetail)
    tokenGroup.get("tags", use: toTags)
    tokenGroup.get("categories", use: toCategories)
    tokenGroup.get("list", use: toIndex)
    
    let authTokeGroup = tokenGroup.grouped(User.guardMiddleware())
    
    // 评论文章
    authTokeGroup.post("comment", use: addComment)
    // 对评论进行回复
    authTokeGroup.post("comment", "reply", use: commentAddReply)
  }
}

extension WebFrontController {
  private func frontWrapper(_ req: Request, cateId: UUID? = nil, hideNavCate: Bool = false, data: AnyEncodable? = nil, pageMeta:PageMetadata? = nil,  extra: [String: AnyEncodable?]? = nil) async throws -> [String: AnyEncodable?] {
    let user = req.auth.get(User.self)
    let outUser = user?.asPublic()
    let cates = try await req.repositories.category.all(ownerId: outUser?.id)
    let links = try await req.repositories.link.all(ownerId: outUser?.id)
    
    var context: [String: AnyEncodable?] = [
      "cateId": .init(cateId),
      "user": .init(outUser),
      "data": data,
      "pageMeta": PageUtil.genPageMetadata(pageMeta: pageMeta),
      "categories": .init(cates),
      "hideNavCate": .init(hideNavCate),
      "links": .init(links)
    ]
    if let extra = extra {
      context.merge(extra) { $1 }
    }
    return context
  }
  
  private func toDetail(_ req: Request) async throws -> View {
    let user = req.auth.get(User.self)
    let postId: String = req.query["postId"]!
    let post = try await req.repositories.post.get(id: .init(uuidString: postId)!, ownerId: user?.requireID())
    // 获取文章的评论
    let comments = try await req.repositories.comment.all(topicId: .init(uuidString: postId)!, topicType: 1)
    return try await req.view.render("front/detail", frontWrapper(req,
                                                                  hideNavCate: true,
                                                                  data: .init(post),
                                                                  extra: ["comments": .init(comments)]
                                                                 ))
  }
  
  private func toIndex(_ req: Request) async throws -> View {
    let user = req.auth.get(User.self)
    let inIndex = try req.query.decode(InSearchPost.self)
    let posts = try await req.repositories.post.page(ownerId: user?.id, inIndex: inIndex)
    // * 热门标签，按文章数排序， 20个
    let hotTags = try await req.repositories.tag.hot(limit: 20)
    // * 最新发布，按文章时间排序， 10个
    let newerPosts = try await req.repositories.post.newer(limit: 10)
    // * 点击最多，按文章阅读数排序，10个
    
    return try await req.view.render("front/index",
                                     frontWrapper(req,
                                                  cateId: inIndex.categoryId,
                                                  data: .init(posts),
                                                  pageMeta: posts.metadata,
                                                  extra: [
                                                    "listFor": .init(inIndex.listFor),
                                                    "hotTags": .init(hotTags),
                                                    "newerPosts": .init(newerPosts)
                                                  ])
    )
  }
  
  // 所有标签
  private func toTags(_ req: Request) async throws -> View {
    let user = req.auth.get(User.self)
    let tags = try await req.repositories.tag.all(ownerId: user?.id)
    return try await req.view.render("front/tags",frontWrapper(req, data: .init(tags)))
  }
  
  // 所有分类
  private func toCategories(_ req: Request) async throws -> View {
    let user = req.auth.get(User.self)
    let categories = try await req.repositories.category.all(ownerId: user?.id)
    return try await req.view.render("front/categories",frontWrapper(req, data: .init(categories)))
  }
  
  // 添加评论
  private func addComment(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InComment.validate(content: req)
    let param = try req.content.decode(InComment.self)
    let _ = try await req.repositories.comment.add(param: param, fromUserId: user.requireID())
    return OutJson(success: OutOk())
  }
  
  // 获取文章的获取评论列表
  private func commentAddReply(_ req: Request) async throws -> OutJson<OutOk> {
    let user = try req.auth.require(User.self)
    try InReply.validate(content: req)
    let param = try req.content.decode(InReply.self)
    let _ = try await req.repositories.reply.add(param: param, fromUserId: user.requireID())
    return OutJson(success: OutOk())
  }
}
