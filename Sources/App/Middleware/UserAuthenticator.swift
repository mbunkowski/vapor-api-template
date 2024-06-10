import Vapor

struct UserAuthenticator: AsyncBearerAuthenticator {
    
    typealias User = App.User

    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        
    }
}
