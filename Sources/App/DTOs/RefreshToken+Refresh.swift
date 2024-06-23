import Fluent
import Vapor

extension RefreshToken {
    struct Refresh: Content {
        let refresh_token: String
    }
}

extension RefreshToken.Refresh: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("refresh_token", as: String.self)
    }
}
