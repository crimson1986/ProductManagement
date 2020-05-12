//
//  UserConroller.swift
//  App
//
//  Created by Chirag Shah on 5/12/20.
//

import Vapor
import Fluent

struct UserResponse: Content {
    let token: String
    let user: User.Public
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let usersRoute = routes.grouped("users")
        usersRoute.post("signup", use: create)
        
        let passwordProtected = usersRoute.grouped(User.authenticator())
        passwordProtected.post("login", use: login)
        
        let tokenProtected = usersRoute.grouped(Token.authenticator())
        tokenProtected.get("me", use: me)
    }
    
    private func create(req: Request) throws -> EventLoopFuture<UserResponse> {
        try User.Create.validate(req)
        let userCreate = try req.content.decode(User.Create.self)
        let user = try User.create(from: userCreate)
        
        var token: Token!
        
        return checkIfUserExists(userCreate.username, req: req).flatMap { exists in
            guard !exists else {
                return req.eventLoop.future(error: UserError.usernameExist)
            }
            
            return user.save(on: req.db)
        }.flatMap {
            guard let newToken = try? user.generateToken() else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            
            token = newToken
            
            return token.save(on: req.db)
        }.flatMapThrowing {
            UserResponse(token: token.value, user: try user.asPublic())
        }
    }
    
    private func login(req: Request) throws -> EventLoopFuture<UserResponse> {
        let user = try req.auth.require(User.self)
        guard let userType = req.headers.first(name: "user_type"),
            let userTypeInt = Int(userType),
            let type = UserType(rawValue: userTypeInt) else {
            return req.eventLoop.future(error: UserError.userTypeNotExist)
        }
        
        return queryUser(type, req: req)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { (exUser) -> Token in
                let token = try exUser.generateToken()
                return token
        }.flatMap { token in
            return token.save(on: req.db).flatMapThrowing {
                UserResponse(token: token.value, user: try user.asPublic())
            }
        }
    }
    
    private func queryUser(_ type: UserType, req: Request) -> EventLoopFuture<User?> {
      User.query(on: req.db)
        .filter(\.$type == type)
        .first()
    }
    
    private func me(req: Request) throws -> User.Public {
        try req.auth.require(User.self).asPublic()
    }
    
    private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$username == username)
            .first()
            .map { $0 != nil }
    }
    
}
