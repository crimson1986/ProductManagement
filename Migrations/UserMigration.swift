//
//  UserMigration.swift
//  App
//
//  Created by Chirag Shah on 5/12/20.
//

import Fluent

extension User {
    
    struct Migration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
          database.schema(User.schema)
              .field(User.FieldKeys.id, .uuid, .identifier(auto: false))
              .field(User.FieldKeys.passwordHash, .string, .required)
              .field(User.FieldKeys.username, .string, .required)
              .unique(on: User.FieldKeys.username)
              .field(User.FieldKeys.createdAt, .datetime, .required)
              .field(User.FieldKeys.updatedAt, .datetime, .required)
              .field(User.FieldKeys.userType, .int8, .required)
              .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
              database.schema(User.schema).delete()
        }
    }
    
}
