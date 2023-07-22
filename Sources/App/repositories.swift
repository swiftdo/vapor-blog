import Vapor

func repositories(_ app: Application) throws {
  app.repositories.register(UserRepository.self) { req in
      UserRepositoryImpl(req)
  }
  app.repositories.register(InviteRepository.self) { req in
      InviteRepositoryImpl(req)
  }
  app.repositories.register(TagRepository.self) { req in
    TagRepositoryImpl(req)
  }
  app.repositories.register(CategoryRepository.self) { req in
    CategoryRepositoryImpl(req)
  }
  app.repositories.register(PostRepository.self) { req in
    PostRepositoryImpl(req)
  }
  app.repositories.register(LinkRepository.self) { req in
    LinkRepositoryImpl(req)
  }
}
