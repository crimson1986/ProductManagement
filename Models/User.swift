//
//  User.swift
//  App
//
//  Created by Chirag Shah on 5/11/20.
//

import Fluent
import Vapor

enum UserType: Int, Content, CaseIterable {
    case user
    case admin
    case superAdmin
}

final class User: Model {
    
    static let schema: String = "users"
    
    @ID(key: FieldKeys.id)
    var id: UUID?
    
    @Field(key: FieldKeys.username)
    var username: String
    
    @Field(key: FieldKeys.passwordHash)
    var passwordHash: String
    
    @Field(key: FieldKeys.userType)
    var type: UserType
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() {
        
    }
    
    init(id: UUID? = nil,
         username: String,
         passwordHash: String, userType: UserType) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.type = userType
    }
    
    struct Public: Content {
        let id: UUID
        let type: UserType
        let username: String
        let createdAt: Date?
        let updatedAt: Date?
    }
    
    struct FieldKeys {
        static let id: FieldKey = "id"
        static let username: FieldKey = "username"
        static let passwordHash: FieldKey = "password_hash"
        static let userType: FieldKey = "user_type"
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }
    
}

extension User {
    
    static func create(from userSignup: Create) throws -> User {
        User(username: userSignup.username, passwordHash: try Bcrypt.hash(userSignup.password), userType: userSignup.userType)
    }
    
    func generateToken() throws -> Token {
      let calendar = Calendar(identifier: .gregorian)
      let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
      return try Token(userId: requireID(),
        token: [UInt8].random(count: 16).base64, expiresAt: expiryDate)
    }
    
    func asPublic() throws -> Public {
        Public(id: try requireID(), type: self.type, username: username, createdAt: createdAt, updatedAt: updatedAt)
    }
    
}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$username
    
    static var passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
