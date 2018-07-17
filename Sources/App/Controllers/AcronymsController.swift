import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    /*
     router.post("api", "acronyms") route handler.
     router.get("api", "acronyms", Acronym.parameter)
     router.put("api", "acronyms", Acronym.parameter)
     router.delete("api", "acronyms", Acronym.parameter)
     router.get("api", "acronyms", "search")
     router.get("api", "acronyms", "first")
     router.get("api", "acronyms", "sorted")
     */
    func boot(router: Router) throws {
        
        //单独形式
        //        router.get("api", "acronyms", use: getAllHandler)
        //按组形式
        let acronyms_routes = router.grouped("api", "acronyms")
        
        acronyms_routes.get(use: getAllHandler)
        //1.创建数据
        //        acronyms_routes.post(use: createHandler)
        acronyms_routes.post(Acronym.self, use: createHandler)
        
        //2.获取数据
        acronyms_routes.get(Acronym.parameter, use: getHandler)
        //3.更新数据
        acronyms_routes.put(Acronym.parameter, use: updateHandler)
        //4.删除数据
        acronyms_routes.delete(Acronym.parameter, use: deleteHandler)
        //5.搜索
        acronyms_routes.get("search", use: searchHandler)
        //6.获取首条数据
        acronyms_routes.get("first", use: getFirstHandler)
        //7.数据排序
        acronyms_routes.get("sorted", use: sortedHandler)
        //8.通过关系获取数据
        acronyms_routes.get(Acronym.parameter, "user", use: getUserHandler)
        //9.增加兄弟姐妹关系 /api/acronyms/<ACRONYM_ID>/categories/<CATEGORY_ID>
        /*
         URL: http://localhost:8080/api/acronyms/1/categories/1
         method: POST
         在ID 1的首字母缩写和ID 1的类别之间建立了兄弟关系，这是您在本章前面创建的。单击Send Request，您将看到一个201创建的响应:
         HTTP/1.1 201 Created
         content-length: 0
         date: Tue, 03 Jul 2018 08:32:08 GMT
         */
        acronyms_routes.post(Acronym.parameter, "categories", Category.parameter, use: self.addCategoriesHandler)
        //10.查询关系 URL: http://localhost:8080/api/acronyms/1/categories method: GET
        acronyms_routes.get(Acronym.parameter, "categories", use: self.getCategoriesHandler)
    }
    
    //查找所有数据
    func getAllHandler(_ request: Request) throws -> Future<[Acronym]> {
        
        return Acronym.query(on: request).all()
    }
    
    //创建
    //    func createHandler(_ request: Request) throws -> Future<Acronym> {
    //
    //        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self, { acronym in
    //
    //            return acronym.save(on: request)
    //        })
    //
    ////        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
    ////
    ////            return acronym.save(on: request)
    ////        }
    //    }
    
    //创建 新
    func createHandler(_ request: Request , acronym: Acronym) throws -> Future<Acronym> {
        
        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self, { acronym in
            
            return acronym.save(on: request)
        })
        
    }
    
    //获取单个数据
    func getHandler(_ request: Request) throws -> Future<Acronym> {
        
        return try request.parameters.next(Acronym.self)
    }
    
    //更新（修改）数据
    func updateHandler(_ request: Request) throws -> Future<Acronym> {
        
        return try flatMap(to: Acronym.self, request.parameters.next(Acronym.self), request.content.decode(Acronym.self), { acronym, update_acronym in
            
            acronym.short = update_acronym.short
            acronym.long = update_acronym.long
            acronym.userID = update_acronym.userID
            
            
            return acronym.save(on: request)
        })
    }
    
    //删除单个数据
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        
        return try request.parameters.next(Acronym.self).delete(on: request).transform(to: HTTPStatus.noContent)
    }
    
    //搜索
    func searchHandler(_ request: Request) throws -> Future<[Acronym]> {
        
        guard let search_term = request.query[String.self, at: "term"] else { throw Abort(.badRequest)}
        
        return Acronym.query(on: request).group(.or) { or in
            
            or.filter(\Acronym.short == search_term)
            or.filter(\Acronym.long == search_term)
            
            }.all()
    }
    
    //获取结果中的首条数据
    func getFirstHandler(_ request: Request) throws -> Future<Acronym> {
        
        return Acronym.query(on: request).first().map(to: Acronym.self, { (acronym) -> Acronym in
            
            guard let acronym = acronym else { throw Abort(.notFound)}
            
            return acronym
        })
    }
    
    //排序
    func sortedHandler(_ request: Request) throws -> Future<[Acronym]> {
        
        return Acronym.query(on: request).sort(\Acronym.id , .ascending).all()
    }
    
    //parent child relationship 父子关系
    func getUserHandler(_ request: Request) throws -> Future<User> {
        
        return try request.parameters.next(Acronym.self).flatMap(to: User.self, { acronym in
            
            acronym.user.get(on: request)
        })
    }
    
    //Sibling relationships 兄弟姐妹关系
    func addCategoriesHandler(_ request: Request) throws -> Future<HTTPStatus> {
        
        return try flatMap(to: HTTPStatus.self, request.parameters.next(Acronym.self), request.parameters.next(Category.self), { acronym, category in
            
            let pivot = try AcronymCategoryPivot(acronym.requireID(), category.requireID())
            
            return pivot.save(on: request).transform(to: .created)
        })
    }
    
    //AcronymsController.swift 查询关系
    func getCategoriesHandler(_ request: Request) throws -> Future<[Category]> {
        
        return try request.parameters.next(Acronym.self).flatMap(to: [Category].self) { acronym in
            
            try acronym.categories.query(on: request).all()
        }
    }
}

