import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.group("api") { route in
        try! route.register(collection: AuthController())
    }
    
}
