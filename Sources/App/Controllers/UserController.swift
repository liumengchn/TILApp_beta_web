import Vapor

struct UserController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let user_route = router.grouped("api", "users")
        
        user_route.post(User.self, use: self.createHandler)
        user_route.get(use: self.getAllHandler)
        user_route.get(User.parameter, use: self.getHandler)
        user_route.get(User.parameter, "acronyms", use: self.getAcronymsHandler)
    }
    
    //创建数据
    func createHandler(_ request: Request, user: User) throws -> Future<User> {
        
        return user.save(on: request)
    }
    
    //获取一条数据
    func getHandler(_ request: Request) throws -> Future<User> {
        
        return try request.parameters.next(User.self)
    }
    
    //获取所有数据
    func getAllHandler(_ request: Request) throws -> Future<[User]> {
        
        return User.query(on: request).all()
    }
    
    //获取子关系数据
    func getAcronymsHandler(_ request: Request) throws -> Future<[Acronym]> {
        
        return try request.parameters.next(User.self).flatMap(to: [Acronym].self, { user in
            
            try user.acronyms.query(on: request).all()
        })
    }
}

