import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("user", "register", use: self.create)
    }

    @Sendable
    func create(req: Request) async throws -> UserDTO {
        try User.Create.validate(content: req)
        let createUser = try req.content.decode(User.Create.self)
        guard try await User.query(on: req.db).filter(\User.$email, .equal, createUser.email).first() == nil else {
            throw Abort(.conflict, reason: "Email is already registered.")
        }
        let passwordHash = try await req.password.async.hash(createUser.password)
        let user = User(email: createUser.email, passwordHash: passwordHash)
        try await user.save(on: req.db)
        return user.toDTO()
    }
}
