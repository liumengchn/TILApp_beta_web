import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
    
    var id: Int?
    var short: String
    var long: String
    var userID: User.ID
    
    //查询关系 AcronymsController.swift AcronymsController.swift
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        
        return siblings()
    }
    
    init(short: String, long: String, userID: User.ID) {
        
        self.short = short
        self.long = long
        self.userID = userID
    }
}

extension Acronym: PostgreSQLModel {}

////设置外键
//extension Acronym: Migration {
//
//    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
//
//        return Database.create(self, on: connection, closure: { builder in
//
//            try addProperties(to: builder)
////            try Acronym.addProperties(to: builder)
//            builder.reference(from: \Acronym.userID, to: \User.id)
//        })
//    }
//}

extension Acronym: Content {}

//Retrieve a single acronym
extension Acronym: Parameter {}

//gettting the parent
extension Acronym {
    
    var user: Parent<Acronym, User> { return parent(\Acronym.userID)}
}

extension Acronym: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            
            //            try Acronym.addProperties(to: builder)
            try addProperties(to: builder)
            //            try builder.addReference(from: \.userID, to: \User.id)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

