//
//  TokenMigration.swift
//  App
//
//  Created by Chirag Shah on 5/12/20.
//

import Fluent

extension Token {
  
    struct Migration: Fluent.Migration {

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Token.schema)
                .field(Token.FieldKeys.id, .uuid, .identifier(auto: false))
                .field(Token.FieldKeys.user, .uuid, .references(User.schema, User.FieldKeys.id))
                .field(Token.FieldKeys.value, .string, .required)
                .unique(on: Token.FieldKeys.value)
                .field(Token.FieldKeys.createdAt, .datetime, .required)
                .field(Token.FieldKeys.expiresAt, .datetime)
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Token.schema).delete()
        }
        
    }
    
}
