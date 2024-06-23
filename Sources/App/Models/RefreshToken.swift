import Vapor
import Fluent
import struct Foundation.UUID

final class RefreshToken: Model, @unchecked Sendable {
    static let schema = "refresh_tokens"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var token: String
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Parent(key: "user_id")
    var user: User

    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    init() { }

    init(userId: UUID, token: String, expiresAt: Date) {
        self.$user.id = userId
        self.token = token
        self.expiresAt = expiresAt
    }
}
