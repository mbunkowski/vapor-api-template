import Vapor
import JWT

struct JWT: Content, Authenticatable, JWTPayload {

    static let expirationTime: TimeInterval = 60 * 15

    var expiration: ExpirationClaim
    var userId: UUID

    init(userId: UUID) {
        self.userId = userId
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(JWT.expirationTime))
    }

    init(with user: User) throws {
        self.userId = try user.requireID()
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(JWT.expirationTime))
    }

    func verify(using algorithm: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
    }
}
