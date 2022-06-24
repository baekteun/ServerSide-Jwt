import Vapor
import Queues
import QueuesRedisDriver
import Redis

func queues(_ app: Application) throws {
    if app.environment != .testing {
        try app.queues.use(
            .redis(
                url: "redis://127.0.0.1:6379"
            )
        )
    }
}
