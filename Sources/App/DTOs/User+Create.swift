//
//  File.swift
//  
//
//  Created by Mateusz Bunkowski on 6/9/24.
//

import Foundation
import Fluent
import Vapor

extension User {
    struct Create: Content {
        var email: String
        var password: String
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}
