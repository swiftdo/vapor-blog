import Fluent
import SMTP
import Vapor

public struct AuthServiceImpl: AuthService {

  var req: Request

  public init(_ req: Request) {
    self.req = req
  }
  
  func registerSystemAdmin() async throws -> User {
    
    /// 生成邀请码
    let inviteCode = try await req.repositories.invite.generateInviteCode()
  
    let user = User(
      name: Constants.superAdminName,
      email: Constants.superAdminEmail,
      isAdmin: true,
      isEmailVerified: true,
      inviteCode: inviteCode
    )
    try await user.create(on: req.db)
    let pwd = try await req.password.async.hash(Constants.superAdminPwd)
    let ua = try UserAuth(
      userId: user.requireID(), authType: "email", identifier: Constants.superAdminEmail, credential: pwd)
    try await ua.create(on: req.db)
    return user
  }

  func login() async throws -> OutJson<OutToken> {
    try InLogin.validate(content: req)
    let inLogin = try req.content.decode(InLogin.self)
    let (isAuth, userAuth) = try await isValidPwd(email: inLogin.email, pwd: inLogin.password)
    guard isAuth else {
      throw ApiError(code: .invalidEmailOrPassword)
    }
    let user = try await userAuth.$user.get(on: req.db)
    return OutJson(success: try getUserToken(user: user, req: req))
  }

  /// 注册
  func register() async throws -> OutJson<OutOk> {
    try InRegister.validate(content: req)
    let inRegister = try req.content.decode(InRegister.self)
    let userAuth = try await getUserAuth(email: inRegister.email, req: req)
    guard userAuth == nil else {
      throw ApiError(code: .userExist)
    }
    let role = try await Role.query(on: req.db).filter(\.$name == Constants.userRoleName).first()
    guard let role = role else {
      throw ApiError(code: .userRoleNotExist)
    }
    let emailCode = try await validEmailCode(
      type: "register",
      email: inRegister.email,
      code: inRegister.code,
      req: req)
    /// 生成邀请码
    let inviteCode = try await req.repositories.invite.generateInviteCode()

    let user = User(
      name: inRegister.name, email: inRegister.email, isEmailVerified: true, inviteCode: inviteCode
    )

    if let inCode = inRegister.inviteCode, !inCode.isEmpty {
      /// 获取到邀请者
      let inviteUser =
        try await User
        .query(on: req.db)
        .filter(\.$inviteCode == inCode)
        .first()
      guard let inviteUser = inviteUser else {
        throw ApiError(code: .inviteUserNotExist)
      }
      user.superiorId = inviteUser.id
    }
    try await user.create(on: req.db)
    let pwd = try await req.password.async.hash(inRegister.password)
    let ua = try UserAuth(
      userId: user.requireID(), authType: "email", identifier: inRegister.email, credential: pwd)
    try await ua.create(on: req.db)
    emailCode.status = 1
    try await emailCode.save(on: req.db)
    try await user.$roles.attach(role, method: .ifNotExists, on: req.db)
    return OutJson(success: OutOk())
  }

  /// 账号注销
  func deleteUser() async throws -> OutJson<OutOk> {
    let payload = try req.auth.require(SessionToken.self)
    let user = try await User.find(payload.userId, on: req.db)
    guard let user = user else {
      throw ApiError(code: .userNotExist)
    }
    let userAuth = try await UserAuth.query(on: req.db)
      .filter(\.$identifier == user.email)
      .filter(\.$authType == "email")
      .first()

    guard let userAuth = userAuth else {
      throw ApiError(code: .userNotExist)
    }
    try await userAuth.delete(force: true, on: req.db)
    try await user.delete(force: true, on: req.db)
    return OutJson(success: OutOk())
  }

  /// 忘记密码，进行重置
  func resetpwd() async throws -> OutJson<OutOk> {
    try InResetpwd.validate(content: req)
    let inResetpwd = try req.content.decode(InResetpwd.self)

    // 通过邮箱找到这个用户
    let userAuth = try await getUserAuth(email: inResetpwd.email, req: req)
    guard let userAuth = userAuth else {
      throw ApiError(code: .userNotExist)
    }
    let emailCode = try await validEmailCode(
      type: "resetpwd", email: inResetpwd.email, code: inResetpwd.code, req: req)
    let pwd = try await req.password.async.hash(inResetpwd.pwd)
    // 更新为新密码
    userAuth.credential = pwd
    try await userAuth.save(on: req.db)
    // 将其保存
    emailCode.status = 1
    try await emailCode.save(on: req.db)
    return OutJson(success: OutOk())
  }

  /// 更新密码
  func updatepwd() async throws -> OutJson<OutOk> {
    let _ = try req.auth.require(SessionToken.self)
    try InUpdatepwd.validate(content: req)
    let inUpdatepwd = try req.content.decode(InUpdatepwd.self)
    // 判断密码是否正确
    let (isAuth, userAuth) = try await isValidPwd(email: inUpdatepwd.email, pwd: inUpdatepwd.pwd)
    guard isAuth else {
      throw ApiError(code: .invalidEmailOrPassword)
    }
    let pwd = try await req.password.async.hash(inUpdatepwd.newpwd)
    userAuth.credential = pwd
    try await userAuth.save(on: req.db)
    return OutJson(success: OutOk())
  }

  /// 刷新token
  func refreshAccessToken() async throws -> OutJson<OutToken> {
    let inRefreshToken = try req.content.decode(InRefreshToken.self)
    let jwtPayload = try req.jwt.verify(inRefreshToken.refreshToken, as: RefreshToken.self)
    let user = try await User.find(jwtPayload.userId, on: req.db)
    guard let user = user else {
      throw ApiError(code: OutStatus.userNotExist)
    }
    return OutJson(success: try getUserToken(user: user, req: req))
  }

  /// 获取注册验证码
  func getRegisterCode() async throws -> OutJson<OutOk> {
    try InCode.validate(content: req)
    let inCode = try req.content.decode(InCode.self)
    let code = String.randomDigits(ofLength: 6)

    let codeType = "register"

    // 删除老的
    try await EmailCode.query(on: req.db)
      .filter(\.$email == inCode.email)
      .filter(\.$type == codeType)
      .delete()

    let emailCode = EmailCode(email: inCode.email, code: code, type: codeType)
    try await emailCode.create(on: req.db)
    sendEmail(to: inCode.email, msg: "本次请求验证码：\(code)", title: "【表情包】-- 注册验证码", req: req)
    return OutJson(success: OutOk())
  }

  // 获取忘记密码的验证码
  func getResetPwdCode() async throws -> OutJson<OutOk> {
    try InCode.validate(content: req)
    let inCode = try req.content.decode(InCode.self)
    let code = String.randomDigits(ofLength: 6)
    let codeType = "resetpwd"

    // 删除老的
    try await EmailCode.query(on: req.db)
      .filter(\.$email == inCode.email)
      .filter(\.$type == codeType)
      .delete()

    let emailCode = EmailCode(email: inCode.email, code: code, type: codeType)
    try await emailCode.create(on: req.db)
    sendEmail(to: inCode.email, msg: "本次请求验证码：\(code)", title: "【表情包】-- 重置密码验证码", req: req)
    return OutJson(success: OutOk())
  }

  /// utils
  /// 获取用户 token
  private func getUserToken(user: User, req: Request) throws -> OutToken {
    let payload = try SessionToken(user: user)
    let refreshPayload = try RefreshToken(user: user)
    let token = try req.jwt.sign(payload)
    let refreshToken = try req.jwt.sign(refreshPayload)
    return OutToken(token: token, refreshToken: refreshToken)
  }

  private func getUserAuth(email: String, req: Request) async throws -> UserAuth? {
    return try await UserAuth.query(on: req.db)
      .filter(\.$authType == "email")
      .filter(\.$identifier == email)
      .first()
  }

  /// 发送电子邮件
  private func sendEmail(to: String, msg: String, title: String, req: Request) {
    let email = Email(
      from: EmailAddress(address: Environment.get("SMTP_USERNAME")!, name: "iBlog"),
      to: [EmailAddress(address: to)], subject: title, body: msg)
    let client = SMTP(application: req.application, on: req.eventLoop)
    _ = client.send(email)
  }

  // 判断密码是否正确
  func isValidPwd(email: String, pwd: String) async throws -> (Bool, UserAuth) {
    let ua = try await getUserAuth(email: email, req: req)
    guard let userAuth = ua else {
      throw ApiError(code: .userNotExist)
    }
    let isAuth = try await req.password.async.verify(pwd, created: userAuth.credential)
    return (isAuth, userAuth)
  }

  // 验证状态码是否正确
  private func validEmailCode(type: String, email: String, code: String, req: Request) async throws
    -> EmailCode
  {
    let emailCode = try await EmailCode.query(on: req.db)
      .filter(\.$type == type)
      .filter(\.$status == 0)  // 未使用
      .filter(\.$email == email)
      .filter(\.$code == code)
      .sort(\.$createdAt, .descending)
      .first()

    guard let emailCode = emailCode else {
      throw ApiError(code: .invalidEmailCode)
    }

    let interval = emailCode.createdAt!.timeIntervalSinceNow
    // 判断验证码是否过期, 10 分钟内过期
    if -1 * interval > 10 * 60 {
      req.logger.log(level: .info, "\(interval)")
      throw ApiError(code: OutStatus.emailCodeExpired)
    }
    return emailCode
  }
}
