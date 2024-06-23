import Fluent
import Vapor
import JWT

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("auth") { user in
            user.post("register", use: self.create)
            user.post("login", use: self.login)
            user.grouped(UserAuthenticator(), User.guardMiddleware()).post("refresh-token", use: self.refreshToken)
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
        let refreshToken = try await generateRefreshToken(req: req, user: user)
        return TokensDTO(access_token: token, expires_at: payload.expiration.value, refresh_token: refreshToken.token)
    }
    
    @Sendable
    func refreshToken(req: Request) async throws -> TokensDTO {
        try RefreshToken.Refresh.validate(content: req)
        let user = try req.auth.require(User.self)
        let reqToken = try req.content.decode(RefreshToken.Refresh.self)
        
        guard let dbToken = try await RefreshToken.query(on: req.db).filter(\RefreshToken.$token == reqToken.refresh_token).first() else {
            throw Abort(.badRequest)
        }
        
        guard user.id == dbToken.$user.id else {
            throw Abort(.unauthorized)
        }
        
        try await dbToken.delete(on: req.db)
        
        guard dbToken.expiresAt > Date() else {
            throw Abort(.badRequest, reason: "Token expired.")
        }
        
        let jwt = try generateJWT(req: req, user: user)
        let token = try await req.jwt.sign(jwt)
        let refreshToken = try await generateRefreshToken(req: req, user: user)
        return TokensDTO(access_token: token, expires_at: jwt.expiration.value, refresh_token: refreshToken.token)
    }
    
    private func generateJWT(req: Request, user: User) throws -> JWT {
        return try JWT(with: user)
    }
    
    private func generateRefreshToken(req: Request, user: User) async throws -> RefreshToken {
        let refreshToken = RefreshToken(userId: try user.requireID(), token: generate(bits: 256), expiresAt: Date().addingTimeInterval(60*60))
        try await refreshToken.save(on: req.db)
        return refreshToken
    }
    
    private func generate(bits: Int) -> String {
        [UInt8].random(count: bits / 8).hex
    }
}
