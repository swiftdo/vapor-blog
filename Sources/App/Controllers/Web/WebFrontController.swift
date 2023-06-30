
import Fluent
import Vapor

struct WebFrontController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    routes.get(use: toIndex)
  }
}

extension WebFrontController {
    private func toIndex(_ req: Request) async throws -> View {
        return try await req.view.render("front/index", ["name": "Blog"])
    }
}