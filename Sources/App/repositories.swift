import Vapor

func repositories(_ app: Application) throws {
    app.repositories.register(UserRepository.self) { req in
        UserRepositoryImpl(req)
    }
    app.repositories.register(InviteRepository.self) { req in
        InviteRepositoryImpl(req)
    }
}
