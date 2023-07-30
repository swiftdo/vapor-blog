import Fluent
import SMTP
import Vapor

public struct BackendServiceImpl: BackendService {
  var req: Request

  public init(_ req: Request) {
    self.req = req
  }

  func checkPermission(by code: String, user: User) async throws -> Bool {
    var roles: [Role] = []
    if user.$roles.value == nil {
      roles = try await user.$roles.query(on: req.db).all()
    } else {
      roles = user.$roles.value!
    }

    // 并发执行
    var allPerms:[Permission] = []
    try await withThrowingTaskGroup(of: [Permission].self) { group in
       for role in roles {
         group.addTask { try await role.$permissions.query(on: req.db).all() }
       }
      for try await ret in group {
        allPerms.append(contentsOf: ret)
      }
    }
    return allPerms.contains(where: {$0.code == code})
  }
  
  func menus(user: User) async throws -> [Menu.Public] {
    let menus = try await req.repositories.menu.all(ownerId: user.requireID())
    return menus
  }

}
