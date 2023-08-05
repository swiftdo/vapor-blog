import Fluent
import FluentPostgresDriver
import JWT
import Leaf
import LeafKit
import SMTP
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  app.jwt.signers.use(.hs256(key: "blog123"))
  app.middleware = .init()
  app.middleware.use(RouteLoggingMiddleware(logLevel: .info))
  app.middleware.use(ErrorMiddleware.custom(environment: app.environment))

  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  app.views.use(.leaf)
  app.leaf.tags["jsonb"] = Json2B64Tag()
  app.leaf.tags["bjson"] = B642JsonTag()

  let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
    allowedHeaders: [
      .accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent,
      .accessControlAllowOrigin,
    ]
  )
  let cors = CORSMiddleware(configuration: corsConfiguration)
  // cores 需要放到最前面
  app.middleware.use(cors, at: .beginning)
  
  app.databases.use(.postgres(configuration: .init(
           hostname: Environment.get("DATABASE_HOST")!,
           port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
           username: Environment.get("DATABASE_USERNAME")!,
           password: Environment.get("DATABASE_PASSWORD"),
           database: Environment.get("DATABASE_NAME"),
           tls: .disable
//           tls: .prefer(try .init(configuration: .clientDefault))
    )
  ), as: .psql)

  // 配置session
  app.sessions.use(.fluent)
  app.migrations.add(SessionRecord.migration)
    
  /// 添加邮箱服务
  app.smtp.use(
    SMTPServerConfig(
      hostname: Environment.get("SMTP_HOST")!,
      port: Environment.get("SMTP_PORT").flatMap(Int.init(_:)) ?? 465,
      username: Environment.get("SMTP_USERNAME")!,
      password: Environment.get("SMTP_PASSWORD")!,  // ZNZEIMJTGRWQSHOB， 第三方生成秘钥
      tlsConfiguration: .regularTLS
    )
  )

  try migrations(app)
  try routes(app)
  try services(app)
  try repositories(app)
}
