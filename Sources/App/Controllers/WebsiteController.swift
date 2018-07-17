import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.get(use: self.indexHandler)
        router.get("acronyms", Acronym.parameter, use: self.acronymHandler)
    }
    
    func indexHandler(_ request: Request) throws -> Future<View> {
        
//        let context = IndexContext(title: "Home_page")
//
//        return try request.view().render("index", context)
        
        return Acronym.query(on: request).all().flatMap(to: View.self, { acronyms in

            let acronyms_data = acronyms.isEmpty ? nil : acronyms

            let context = IndexContext(title: "HomePage" , acronyms: acronyms_data)

            return try request.view().render("index", context)
        })
    }
    
    func acronymHandler(_ request: Request) throws -> Future<View> {
        
        return try request.parameters.next(Acronym.self).flatMap(to: View.self, { acronym in
            
            return acronym.user.get(on: request).flatMap(to: View.self, { user in
                
                let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                
                return try request.view().render("acronym", context)
            })
        })
    }
    
}

struct IndexContext: Encodable {
    
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    
    let title: String
    let acronym: Acronym
    let user: User
}
