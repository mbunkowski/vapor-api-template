import Fluent
import Vapor
import JWT

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("auth") { user in
            user.post("register", use: self.create)
            user.post("login", use: self.login)
        }
    }

    @Sendable
    func create(req: Request) async throws -> TokensDTO {
        try User.Create.validate(content: req)
        let createUser = try req.content.decode(User.Create.self)
        guard try await User.query(on: req.db).filter(\User.$email, .equal, createUser.email).first() == nil else {
            throw Abort(.conflict, reason: "Email is already registered.")
        }
        let passwordHash = try await req.password.async.hash(createUser.password)
        let user = User(email: createUser.email.lowercased(), passwordHash: passwordHash)
        try await user.save(on: req.db)
        return try await login(req: req)
    }
    
    @Sendable
    func login(req: Request) async throws -> TokensDTO {
        try User.Login.validate(content: req)
        let userLogin = try req.content.decode(User.Login.self)
        guard let user = try await User.query(on: req.db).filter(\User.$email == userLogin.email).first() else {
            throw Abort(.badRequest)
        }
        guard try await req.password.async.verify(userLogin.password, created: user.passwordHash) else {
            throw Abort(.badRequest)
        }
        let payload = try JWT(with: user)
        let token = try await req.jwt.sign(payload)
        return TokensDTO(access_token: token, expires_at: payload.expiration.value)
    }
}
