//
//  UserErrors.swift
//  App
//
//  Created by Chirag Shah on 5/12/20.
//

import Vapor

enum UserError {
    case usernameExist
    case userTypeNotExist
}

extension UserError: AbortError {
  var description: String {
    reason
  }

  var status: HTTPResponseStatus {
    switch self {
    case .usernameExist: return .conflict
    case .userTypeNotExist: return .notFound
    }
  }

  var reason: String {
    switch self {
    case .usernameExist: return "Username already exist"
    case .userTypeNotExist: return "User type not exist"
    }
  }
}
