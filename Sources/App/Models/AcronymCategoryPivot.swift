import Foundation
import FluentPostgreSQL



//Sibling relationships 兄弟姐妹关系
final class AcronymCategoryPivot: PostgreSQLUUIDPivot {
    
    var id: UUID?
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    typealias Left = Acronym
    typealias Right = Category
    
    static var leftIDKey: LeftIDKey = \AcronymCategoryPivot.acronymID
    static var rightIDKey: RightIDKey = \AcronymCategoryPivot.categoryID
    
    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

//增加外键约束
extension AcronymCategoryPivot: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) {builder in
            
            //            try addProperties(to: builder)
            
            try AcronymCategoryPivot.addProperties(to: builder)
            try builder.addReference(from: \.acronymID, to: \Acronym.id)
            //            builder.reference(from: \.acronymID, to: \Acronym.id)
            try builder.addReference(from: \.categoryID, to: \Category.id)
            //            builder.reference(from: \.categoryID, to: \Category.id)
            
        }
    }
}

//接下来 AcronymsController.swift

