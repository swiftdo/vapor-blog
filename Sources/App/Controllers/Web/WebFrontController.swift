
import Fluent
import Vapor

struct WebFrontController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    
    let tokenGroup = routes.grouped(WebSessionAuthenticator())
    tokenGroup.get(use: toIndex)
  }
}

extension WebFrontController {
    private func toIndex(_ req: Request) async throws -> View {
      let user = req.auth.get(User.self)
      let outUser = user?.asPublic()
      
      req.logger.info(.init(stringLiteral: outUser?.email ?? "wu"))
        // 获取到当前用户信息
      return try await req.view.render("front/index", ["user": outUser])
    }
}
