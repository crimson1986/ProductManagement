//
//  UserCreate.swift
//  App
//
//  Created by Chirag Shah on 5/12/20.
//

import Fluent
import Vapor

extension User {
    struct Create: Content {
        let username: String
        let password: String
        let userType: UserType
        
        static let usernameValidationKey: ValidationKey = "username"
        static let passwordValidationKey: ValidationKey = "password"
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add(User.Create.usernameValidationKey, as: String.self, is: !.empty)
        validations.add(User.Create.passwordValidationKey, as: String.self, is: .count(8...))
    }
}
