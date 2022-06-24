import Vapor

func migrations(_ app: Application) throws {
    app.migrations.add(CreateUser())
    app.migrations.add(CreateRefreshToken())
}
