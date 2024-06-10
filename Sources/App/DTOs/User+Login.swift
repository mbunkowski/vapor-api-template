import Fluent
import Vapor

extension User {
    struct Login: Content {
        var email: String
        var password: String
    }
}

extension User.Login: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self)
        validations.add("password", as: String.self)
    }
}
