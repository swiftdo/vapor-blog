import Fluent
import Vapor

func routes(_ app: Application) throws {
  
  // Api
  let apiGroup = app.grouped("api")
  try apiGroup.register(collection: AuthController())
  
  // 前端
  try app.grouped(app.sessions.middleware).register(collection: WebFrontController())

  // 后台
  let webGroup = app.grouped("web").grouped(app.sessions.middleware)
  try webGroup.grouped("auth").register(collection: WebAuthController())
  try webGroup.grouped("backend").register(collection: WebBackendController())
}
