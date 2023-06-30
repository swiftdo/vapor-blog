import Fluent
import Vapor

func routes(_ app: Application) throws {

  // 前端
  try app.register(collection: WebFrontController())

  // 拦截报错
  let apiGroup = app.grouped("api")
  try apiGroup.register(collection: AuthController())

  let webGroup = app.grouped("web")
  try webGroup.register(collection: WebAuthController())
}
