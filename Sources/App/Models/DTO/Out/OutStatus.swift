//
//  File.swift
//
//
//  Created by laijihua on 2023/6/13.
//

protocol OutCodeMsg {
  var code: Int { get }
  var message: String { get }
}

struct OutStatus: Out, OutCodeMsg {
  var code: Int
  var message: String

  init(code: Int, message: String) {
    self.code = code
    self.message = message
  }
}

// 状态值
extension OutStatus {
  static var ok = OutStatus(code: 0, message: "请求成功")
  static var userExist = OutStatus(code: 20, message: "用户已经存在")
  static var userNotExist = OutStatus(code: 21, message: "用户不存在")
  static var passwordError = OutStatus(code: 22, message: "密码错误")
  static var emailNotExist = OutStatus(code: 23, message: "邮箱不存在")
  static var invalidEmailOrPassword = OutStatus(code: 26, message: "邮箱或密码错误")
  static var invalidEmailCode: OutStatus = OutStatus(code: 27, message: "验证码错误")
  static var emailCodeExpired = OutStatus(code: 28, message: "验证码已过期，请重新获取")
  static var inviteUserNotExist = OutStatus(code: 29, message: "邀请码不存在")
  static var postNotExist = OutStatus(code: 30, message: "文章不存在")
  static var roleNotExist = OutStatus(code: 31, message: "角色不存在")
  static var permissionNotExist = OutStatus(code: 32, message: "权限不存在")
  static var userRoleNotExist = OutStatus(code: 33, message: "普通用户角色未设置")
  static var menuNotConfig = OutStatus(code: 34, message: "菜单未配置")
}
