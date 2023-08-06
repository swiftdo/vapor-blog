import Fluent
import Vapor

protocol AuthService: Service {
  // 登录
  func login() async throws -> OutJson<OutToken>
  // 注册
  func register() async throws -> OutJson<OutOk>
  // 删除账号
  func deleteUser() async throws -> OutJson<OutOk>
  // 重置密码
  func resetpwd() async throws -> OutJson<OutOk>
  // 更新密码
  func updatepwd() async throws -> OutJson<OutOk>
  // 刷新登录token
  func refreshAccessToken() async throws -> OutJson<OutToken>
  // 获取注册验证码
  func getRegisterCode() async throws -> OutJson<OutOk>
  // 获取重置密码验证码
  func getResetPwdCode() async throws -> OutJson<OutOk>
  // 判断密码是否有效
  func isValidPwd(email: String, pwd: String) async throws -> (Bool, UserAuth)
  // 注册系统管理员
  func registerSystemAdmin() async throws -> User
}

extension ServiceFactory {
  var auth: AuthService {
    guard let result = resolve(AuthService.self) as? AuthService else {
      fatalError("AuthService is not configured")
    }
    return result
  }
}
