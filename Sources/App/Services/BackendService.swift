import Fluent
import Vapor

protocol BackendService: Service {
  // 判断用户是否具有权限
  func checkPermission(by code:String, user: User) async throws -> Bool
  
  // 获取用户的菜单
  func menus(user: User) async throws -> [Menu.Public]
}

extension ServiceFactory {
  var backend: BackendService {
    guard let result = resolve(BackendService.self) as? BackendService else {
      fatalError("BackendService is not configured")
    }
    return result
  }
}

