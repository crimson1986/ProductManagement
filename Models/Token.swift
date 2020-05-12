//
//  Token.swift
//  App
//
//  Created by Chirag Shah on 5/12/20.
//

import Fluent
import Vapor

final class Token: Model {
    static let schema: String = "tokens"
    
    @ID(key: FieldKeys.id)
    var id: UUID?
    
    @Field(key: FieldKeys.value)
    var value: String
    
    @Parent(key: FieldKeys.user)
    var user: User
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?
    
    @Field(key: FieldKeys.expiresAt)
    var expiresAt: Date?
    
    init() {
        
    }
    
    init(id: UUID? = nil,
         userId: User.IDValue,
         token: String, expiresAt: Date?) {
        self.id = id
        self.value = token
        self.$user.id = userId
        self.expiresAt = expiresAt
    }
    
    struct FieldKeys {
        static let id: FieldKey = "id"
        static let value: FieldKey = "value"
        static let user: FieldKey = "user_id"
        static let createdAt: FieldKey = "created_at"
        static let expiresAt: FieldKey = "expires_at"
    }
}

extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$value
    static let userKey = \Token.$user
    
    var isValid: Bool {
        guard let expiryDate = expiresAt else {
          return true
        }
        
        return expiryDate > Date()
    }
}
