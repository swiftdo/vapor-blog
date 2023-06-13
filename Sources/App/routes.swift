import Vapor
import Fluent

func routes(_ app: Application) throws {
    
    app.get { req async in
        "It works!"
    }
    
    app.get("hello") { req async throws -> View in
        return try await req.view.render("hello", ["name": "Blog"])
    }
}
