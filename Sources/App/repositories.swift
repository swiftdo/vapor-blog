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
  
  app.repositories.register(RoleRepository.self) { req in
    RoleRepositoryImpl(req)
  }
  app.repositories.register(PermissionRepository.self) { req in
    PermissionRepositoryImpl(req)
  }
  app.repositories.register(MenuRepository.self) { req in
    MenuRepositoryImpl(req)
  }
}
