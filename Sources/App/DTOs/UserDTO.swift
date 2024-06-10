import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var email: String?
}
