import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    /*************************************** AcronymsController ************************************/
    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)
    
    let users_controller = UserController()
    try router.register(collection: users_controller)
    
    let category_controller = CategoriesController()
    try router.register(collection: category_controller)
    
    
    let website_controller = WebsiteController()
    try router.register(collection: website_controller)
    
}
