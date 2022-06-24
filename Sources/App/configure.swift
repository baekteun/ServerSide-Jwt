import Fluent
import FluentPostgresDriver
import Vapor
import Queues
import JWT

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_NAME") ?? "postgres"
    ), as: .psql)
    
    if app.environment != .testing {
        let s = """
"""
        try app.jwt.signers.use(.rs256(key: .private(pem: s)))
    }
    
    app.middleware = .init()
    app.middleware.use(CORSMiddleware(configuration: .default()))
    app.middleware.use(ErrorMiddleware.custom(environment: app.environment))

    try routes(app)
    try migrations(app)
    try services(app)
//    try queues(app)

//    if app.environment == .development {
//        try app.autoMigrate().wait()
//        try app.queues.startInProcessJobs()
//    }
}
