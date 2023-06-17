import Fluent
import Vapor

func routes(_ app: Application) throws {

  app.get { req async throws -> View in
    return try await req.view.render("hello", ["name": "Blog"])
  }

  let apiGroup = app.grouped("api")
  try apiGroup.register(collection: AuthController())

  let webGroup = app.grouped("web")
  try webGroup.register(collection: WebAuthController())
}
