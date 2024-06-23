import Fluent

struct CreateRefreshToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("refresh_tokens")
            .id()
            .field("token", .string, .required)
            .field("user_id", .uuid, .references("users", "id", onDelete: .cascade))
            .field("expires_at", .datetime)
            .field("created_at", .string)
            .unique(on: "token")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("refresh_tokens").delete()
    }
}

