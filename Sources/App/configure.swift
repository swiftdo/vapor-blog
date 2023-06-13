import Vapor
import Fluent
import FluentPostgresDriver
import Leaf
import JWT



// configures your application
public func configure(_ app: Application) async throws {
    app.jwt.signers.use(.hs256(key: "blog123"))
    app.middleware = .init()
    app.middleware.use(RouteLoggingMiddleware(logLevel: .info))
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.routes.defaultMaxBodySize = "100mb"
    app.views.use(.leaf)
    
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
    
    app.databases.use(
        .postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))
                ?? SQLPostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor",
            database: Environment.get("DATABASE_NAME") ?? "blog"
        ),
        as: .psql
    )
    
    try migrations(app)
    try routes(app)
    try services(app)
    try repositories(app)
}
