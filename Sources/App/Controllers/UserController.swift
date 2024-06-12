import Fluent
import Vapor
import JWT

struct UserController: RouteCollection {
  
    func boot(routes: RoutesBuilder) throws {
        routes.group("user") { user in
            user.grouped(UserAuthenticator(), User.guardMiddleware()).get(use: me)
        }
    }
    
    @Sendable
    func me(req: Request) async throws -> UserDTO {
        let user = try req.auth.require(User.self)
        return user.toDTO()
    }
}
