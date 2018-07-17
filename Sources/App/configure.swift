import FluentPostgreSQL
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    
    /*************************************** FluentSQLite ************************************/
    //    /// Register providers first 1.
    //    try services.register(FluentSQLiteProvider())
    //
    //    // Configure a SQLite database 2.
    ////    let sqlite = try SQLiteDatabase(storage: .memory)
    //    let sqlite = try SQLiteDatabase(storage: .file(path: "/Users/liumengchen/Documents/vaporProject/sqlite_dir/db.sqlite"))
    //
    //    /// Register the configured SQLite database to the database config.
    //    var databases = DatabasesConfig()
    //    databases.add(database: sqlite, as: .sqlite)
    //    services.register(databases)
    //
    //        /// Configure migrations 3.
    //        var migrations = MigrationConfig()
    //        migrations.add(model: Acronym.self, database: .sqlite)
    //        services.register(migrations)
    
    /*************************************** FluentPostgreSQL ************************************/
    /// Register providers first 1.
    try services.register(FluentPostgreSQLProvider())
//    try services.register(LeafProvider())
    
    
    // Configure a SQLite database 2.
    var databases = DatabasesConfig()
    
    //3. 本地数据库启用
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                  port:     5432,
                                                  username: "vapor",
                                                  database: "vapor"
//                                                  password: "password"
    )
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    //4.
    /// Configure migrations 3.
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymCategoryPivot.self, database: .psql)
    services.register(migrations)
    
    
    var commandConfig = CommandConfig.default()
    commandConfig.use(RevertCommand.self, as: "revert")
    services.register(commandConfig)
    
    /*************************************** Website ************************************/
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    /*************************************** Custom IP ************************************/
//    let server_confingure = NIOServerConfig.default(hostname: "192.168.1.4", port: 8080)
//    services.register(server_confingure)

}
