
import Fluent
import Vapor
import AnyCodable

struct WebFrontController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    
    let tokenGroup = routes.grouped(WebSessionAuthenticator())
    tokenGroup.get(use: toIndex)
  }
}

extension WebFrontController {
  private func frontWrapper(_ req: Request, cateName: String, data: AnyEncodable? = nil, pageMeta:PageMetadata? = nil,  extra: [String: AnyEncodable?]? = nil) async throws -> [String: AnyEncodable?] {
    let user = req.auth.get(User.self)
    let outUser = user?.asPublic()
    let cates = try await req.repositories.category.all(ownerId: outUser?.id)
    
    var context: [String: AnyEncodable?] = [
      "cateName": .init(cateName),
      "user": .init(outUser),
      "data": data,
      "pageMeta": PageUtil.genPageMetadata(pageMeta: pageMeta),
      "cates": .init(cates)
    ]
    if let extra = extra {
      context.merge(extra) { $1 }
    }
    return context
  }
  
  private func toIndex(_ req: Request) async throws -> View {
    let user = req.auth.get(User.self)
    let posts = try await req.repositories.post.page(ownerId: user?.id)
    return try await req.view.render("front/index",
                                     frontWrapper(req,
                                                  cateName: "首页",
                                                  data: .init(posts),
                                                  pageMeta: posts.metadata))
  }
}
