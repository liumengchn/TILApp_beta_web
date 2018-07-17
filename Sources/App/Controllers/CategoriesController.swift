
import Vapor

struct CategoriesController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let categories_route = router.grouped("api" , "categories")
        
        categories_route.post(Category.self, use: self.createHandler)
        categories_route.get(use: self.getAllHandler)
        categories_route.get(Category.parameter, use: self.getHandler)
        
        // /api/categories/<CATEGORY_ID>/acronyms
        categories_route.get(Category.parameter, "acronyms", use: self.getAcronymsHandler)
    }
    
    
    func createHandler(_ request: Request, category: Category) throws -> Future<Category> {
        
        return category.save(on: request)
    }
    
    func getAllHandler(_ request: Request) throws -> Future<[Category]> {
        
        return Category.query(on: request).all()
    }
    
    func getHandler(_ request: Request) throws -> Future<Category> {
        
        return try request.parameters.next(Category.self)
    }
    
    func getAcronymsHandler(_ request: Request) throws -> Future<[Acronym]> {
        
        return try request.parameters.next(Category.self).flatMap(to: [Acronym].self, { category in
            
            try category.acronyms.query(on: request).all()
        })
    }
    
    
}

