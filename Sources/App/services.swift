import Vapor

func services(_ app: Application) throws {
  app.services.register(AuthService.self) { req in
    return AuthServiceImpl(req)
  }
}
