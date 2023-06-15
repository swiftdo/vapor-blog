import Vapor

func migrations(_ app: Application) throws {
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserAuth())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateTag())
    app.migrations.add(CreateComment())
    app.migrations.add(CreateSideBar())
    app.migrations.add(CreatePost())
    app.migrations.add(CreatePostTag())
    app.migrations.add(CreateLink())
    app.migrations.add(CreateEmailCode())
}
