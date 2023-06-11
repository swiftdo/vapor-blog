import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    try routes(app)
}
