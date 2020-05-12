import Vapor
import Fluent
import FluentSQLiteDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

   let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)
    
    app.databases.use(.sqlite(.file("MyDatabase.sqlite")), as: .sqlite)
    
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    app.migrations.add(User.Migration())
    app.migrations.add(Token.Migration())

    try app.autoMigrate().wait()
    
    try app.register(collection: UserController())
    
    // register routes
    try routes(app)
}
