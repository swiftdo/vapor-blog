
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
    
    return try await req.view.render("front/detail", frontWrapper(req, hideNavCate: true, data: .init(post)))
    
  }
  
  private func toIndex(_ req: Request) async throws -> View {
    let user = req.auth.get(User.self)
    let inIndex = try req.query.decode(InSearchPost.self)
    let posts = try await req.repositories.post.page(ownerId: user?.id, inIndex: inIndex)
    return try await req.view.render("front/index",
                                     frontWrapper(req,
                                                  cateId: inIndex.categoryId,
                                                  data: .init(posts),
                                                  pageMeta: posts.metadata,
                                                  extra: ["listFor": .init(inIndex.listFor)]))
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
  
  // 文章添加评论
  
  // 获取文章的获取评论列表
    
}
