import Fluent
import Vapor

struct TokensDTO: Content {
    var access_token: String
    var expires_at: Date
    var refresh_token: String
}
