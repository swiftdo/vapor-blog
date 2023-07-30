import Fluent
import SMTP
import Vapor

public struct BackendServiceImpl: BackendService {
  var req: Request

  public init(_ req: Request) {
    self.req = req
  }
  
  func checkPermission(by code: String, user: User) async throws -> Bool {
    let allPerms = try await userPermission(user: user)
    return allPerms.contains(where: {$0.code == code})
  }
  
  func menus(user: User) async throws -> [Menu.Public] {
    
    let allPerms = try await userPermission(user: user)
    var menus:[Menu.Public] = []
    if (user.isAdmin) {
      // 系统管理员
      menus = try await req.repositories.menu.all(ownerId: user.id)
    } else {
      menus = try await req.repositories.menu.all(permissions: allPerms)
    }
    return buildMenuTree(menus: menus, parentId: nil)
  }
  
  // private
  private func buildMenuTree(menus: [Menu.Public], parentId: UUID?) -> [Menu.Public] {
    var tree: [Menu.Public] = []
    for menu in menus {
        if menu.parentId == parentId {
            let subMenu = menu.mergeWith(children: buildMenuTree(menus: menus, parentId: menu.id))
            tree.append(subMenu)
        }
    }
    return tree
  }
  
  // 获取用户所有权限
  private func userPermission(user: User) async throws -> [Permission] {
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
    return allPerms
  }

}
