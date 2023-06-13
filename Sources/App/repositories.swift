import Vapor

func repositories(_ app: Application) throws {
    app.repositories.register(UserRepository.self) { req in
        UserRepositoryImpl(req)
    }
}
