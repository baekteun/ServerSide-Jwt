import Fluent
import AsyncKit

struct CreateRefreshToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("refresh_token")
            .id()
            .field("token", .string)
            .field("user_id", .uuid, .references("users", "id", onDelete: .cascade))
            .field("expired_at", .datetime)
            .field("issued_at", .datetime)
            .unique(on: "token")
            .unique(on: "user_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("refresh_token").delete()
    }
}
