import Vapor

struct UserAuthenticator: AsyncBearerAuthenticator {
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let payload = try await request.jwt.verify(bearer.token, as: JWT.self)
        guard let user = try await User.query(on: request.db).filter(\User.$id, .equal, payload.userId).first() else {
            throw Abort(.badRequest)
        }
        request.auth.login(user)
    }
}
