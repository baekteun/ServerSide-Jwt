import Fluent
import AsyncKit

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("full_name", .string, .required)
            .field("phone", .string, .required)
            .field("password", .string, .required)
            .field("is_admin", .bool, .custom("DEFAULT FALSE"))
            .field("is_active", .bool, .custom("DEFAULT FALSE"))
            .unique(on: "phone")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
