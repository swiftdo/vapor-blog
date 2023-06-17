//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/14.
//

import Fluent
import Vapor
import SMTP

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
        auth.post("refresh/token", use: refreshAccessToken)
        auth.post("register/code", use: getRegisterCode)
        auth.post("resetpwd/code", use: getResetPwdCode)
        auth.post("resetpwd", use: resetpwd)

        let secure = auth.grouped(SessionToken.authenticator(), SessionToken.guardMiddleware())
        // 需要登录状态
        secure.post("updatepwd", use: updatepwd)
        secure.post("delete/user", use: deleteUser)
    }
}

extension AuthController {

    /// 登录
    private func login(_ req: Request) async throws -> OutJson<OutToken> {
        try InLogin.validate(content: req)
        let inLogin = try req.content.decode(InLogin.self)
        let (isAuth, userAuth) = try await isValidPwd(email: inLogin.email, pwd: inLogin.password, req: req)
        guard isAuth else {
            throw ApiError(code: .invalidEmailOrPassword)
        }
        let user = try await userAuth.$user.get(on: req.db)
        return OutJson(success: try getUserToken(user: user, req: req))
    }

    /// 注册
    private func register(_ req: Request) async throws -> OutJson<OutOk> {
        try InRegister.validate(content: req)
        let inRegister = try req.content.decode(InRegister.self)
        let userAuth = try await getUserAuth(email: inRegister.email, req: req)
        guard userAuth == nil else {
            throw ApiError(code: .userExist)
        }
        let emailCode = try await validEmailCode(type: "register",
                                                 email: inRegister.email,
                                                 code: inRegister.code,
                                                 req: req)

        let user = User(name: inRegister.name, email: inRegister.email, isEmailVerified: true)
        try await user.create(on: req.db)
        let pwd = try await req.password.async.hash(inRegister.password)
        let ua = try UserAuth(userId: user.requireID(), authType: "email", identifier: inRegister.email, credential: pwd)
        try await ua.create(on: req.db)
        emailCode.status = 1
        try await emailCode.save(on: req.db)
        return OutJson(success: OutOk())
    }

    /// 账号注销
    private func deleteUser(_ req: Request) async throws -> OutJson<OutOk> {
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
    private func resetpwd(_ req: Request) async throws -> OutJson<OutOk> {
        try InResetpwd.validate(content: req)
        let inResetpwd = try req.content.decode(InResetpwd.self)
        
        // 通过邮箱找到这个用户
        let userAuth = try await getUserAuth(email: inResetpwd.email, req: req)
        guard let userAuth = userAuth else {
            throw ApiError(code: .userNotExist)
        }
        let emailCode = try await validEmailCode(type: "resetpwd", email: inResetpwd.email, code: inResetpwd.code, req: req)
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
    private func updatepwd(_ req: Request) async throws -> OutJson<OutOk> {
        let _ = try req.auth.require(SessionToken.self)
        try InUpdatepwd.validate(content: req)
        let inUpdatepwd = try req.content.decode(InUpdatepwd.self)
        // 判断密码是否正确
        let (isAuth, userAuth) = try await isValidPwd(email: inUpdatepwd.email, pwd: inUpdatepwd.pwd, req: req)
        guard isAuth else {
            throw ApiError(code: .invalidEmailOrPassword)
        }
        let pwd = try await req.password.async.hash(inUpdatepwd.newpwd)
        userAuth.credential = pwd
        try await userAuth.save(on: req.db)
        return OutJson(success: OutOk())
    }

    /// 刷新token
    private func refreshAccessToken(_ req: Request) async throws -> OutJson<OutToken> {
        let inRefreshToken = try req.content.decode(InRefreshToken.self)
        let jwtPayload = try req.jwt.verify(inRefreshToken.refreshToken, as: RefreshToken.self)
        let user = try await User.find(jwtPayload.userId, on: req.db)
        guard let user = user else {
            throw ApiError(code: OutStatus.userNotExist)
        }
        return OutJson(success: try getUserToken(user: user, req: req))
    }

    /// 获取验证码
    private func getRegisterCode(_ req: Request) async throws -> OutJson<OutOk> {
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
    private func getResetPwdCode(_ req: Request) async throws -> OutJson<OutOk> {
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
    func getUserToken(user: User, req: Request) throws -> OutToken {
        let payload = try SessionToken(user: user)
        let refreshPayload = try RefreshToken(user: user)
        let token = try req.jwt.sign(payload)
        let refreshToken = try req.jwt.sign(refreshPayload)
        return OutToken(token: token, refreshToken: refreshToken)
    }
    
    func getUserAuth(email: String, req: Request) async throws -> UserAuth? {
        return try await UserAuth.query(on: req.db)
                .filter(\.$authType == "email")
                .filter(\.$identifier == email)
                .first()
    }

    /// 发送电子邮件
    func sendEmail(to: String, msg: String, title: String, req: Request) {
        let email = Email(from: EmailAddress(address: "13576051334@163.com", name: "表情包"), to: [EmailAddress(address: to)], subject: title, body: msg)
        let client  = SMTP(application: req.application, on: req.eventLoop)
        _ = client.send(email)
    }

    // 判断密码是否正确
    func isValidPwd(email: String, pwd: String, req: Request) async throws -> (Bool, UserAuth) {
        let ua = try await getUserAuth(email: email, req: req)
        guard let userAuth = ua else {
            throw ApiError(code: .userNotExist)
        }
        let isAuth = try await req.password.async.verify(pwd, created: userAuth.credential)
        return (isAuth, userAuth)
    }

    // 验证状态码是否正确
    func validEmailCode(type: String, email: String, code: String, req: Request) async throws ->  EmailCode {
        let emailCode = try await EmailCode.query(on: req.db)
            .filter(\.$type == type)
            .filter(\.$status == 0) // 未使用
            .filter(\.$email == email)
            .filter(\.$code == code)
            .sort(\.$createdAt, .descending)
            .first()

        guard let emailCode = emailCode else {
            throw ApiError(code: .invalidEmailCode)
        }

        let interval = emailCode.createdAt!.timeIntervalSinceNow;
        // 判断验证码是否过期, 10 分钟内过期
        if (-1 * interval > 10 * 60) {
            req.logger.log(level: .info, "\(interval)")
            throw ApiError(code: OutStatus.emailCodeExpired)
        }
        return emailCode
    }

}

extension String {
  /// 随机数据
  static func randomDigits(ofLength: Int) -> Self {
    let letters = "0123456789"
    return String((0..<ofLength).map{ _ in letters.randomElement()! })
  }
}
