import Vapor
import Fluent
import struct Foundation.UUID

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String

    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    var updatedAt: Date?
    
    init() { }

    init(id: UUID? = nil, email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
    
    func toDTO() -> UserDTO {
        .init(
            id: self.id,
            email: self.$email.value
        )
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
