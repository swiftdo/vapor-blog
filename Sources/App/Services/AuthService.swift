import Fluent
import Vapor

protocol AuthService: Service {
  // 登录
  func login(_ req: Request) async throws -> OutJson<OutToken>
  // 注册
  func register(_ req: Request) async throws -> OutJson<OutOk>
  // 删除账号
  func deleteUser(_ req: Request) async throws -> OutJson<OutOk>
  // 重置密码
  func resetpwd(_ req: Request) async throws -> OutJson<OutOk>
  // 更新密码
  func updatepwd(_ req: Request) async throws -> OutJson<OutOk>
  // 刷新登录token
  func refreshAccessToken(_ req: Request) async throws -> OutJson<OutToken>
  // 获取注册验证码
  func getRegisterCode(_ req: Request) async throws -> OutJson<OutOk>
  // 获取重置密码验证码
  func getResetPwdCode(_ req: Request) async throws -> OutJson<OutOk>
}

extension ServiceFactory {
  var auth: AuthService {
    guard let result = resolve(AuthService.self) as? AuthService else {
      fatalError("AuthService is not configured")
    }
    return result
  }
}
