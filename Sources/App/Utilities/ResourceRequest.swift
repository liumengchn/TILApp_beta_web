import Vapor

enum GetResourcesRequest<ResourceType> {
    // 1
    case success([ResourceType])
    // 2
    case failure
}

struct ResourceRequest<ResourceType>
where ResourceType: Codable {
    
    // 2
    let baseURL = "https://<YOUR_CLOUD_URL>/api/"
    let resourceURL: URL
    
    // 3
    init(resourcePath: String) {
        guard let resourceURL = URL(string: baseURL) else {
            fatalError()
        }
        self.resourceURL
            = resourceURL.appendingPathComponent(resourcePath)
    }
    
    // 4
    func getAll(completion: @escaping
        (GetResourcesRequest<ResourceType>) -> Void) {
        // 5
        let dataTask = URLSession.shared
            .dataTask(with: resourceURL) {
                data, _, _ in
                // 6
                guard let jsonData = data else {
                    completion(.failure)
                    return
                }
                do {
                    // 7
                    let resources
                        = try JSONDecoder().decode([ResourceType].self,
                                                   from: jsonData)
                    // 8
                    completion(.success(resources))
                } catch {
                    // 9
                    completion(.failure)
                }
        }
        // 10
        dataTask.resume()
    }
}
