import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
    
    var id: UUID?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        
        self.name = name
        self.username = username
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}

//设置外键
extension User: Migration {
    
    
}
extension User: Parameter {}

//获取子关系
extension User {
    
    var acronyms: Children<User, Acronym> { return children(\Acronym.userID)}
}

