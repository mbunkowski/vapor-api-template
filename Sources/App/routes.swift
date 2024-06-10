import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let api = app.grouped("api")
    
    try api.register(collection: UserController())
}
