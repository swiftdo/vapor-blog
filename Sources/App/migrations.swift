import Vapor

func migrations(_ app: Application) throws {
  app.migrations.add(CreateInvite())
  app.migrations.add(CreateUser())
  app.migrations.add(CreateUserAuth())
  app.migrations.add(CreateCategory())
  app.migrations.add(CreateTag())
  app.migrations.add(CreateSideBar())
  app.migrations.add(CreatePost())
  app.migrations.add(CreatePostTag())
  app.migrations.add(CreateLink())
  app.migrations.add(CreateEmailCode())
  
  // 权限管理
  app.migrations.add(CreateRole())
  app.migrations.add(CreateMenu())
  app.migrations.add(CreatePermission())
  app.migrations.add(CreateUserRole())
  app.migrations.add(CreateRolePermission())
  app.migrations.add(CreatePermissionMenu())
  
  // 评论
  app.migrations.add(CreateComment())
  app.migrations.add(CreateReply())
  
  // 通知
  app.migrations.add(CreateMessageInfo())
  app.migrations.add(CreateMessage())
  
  // 自动执行migrations，省去在命令行运行`swift run App migrate`，或编辑scheme的步骤
  try app.autoMigrate().wait()
}
