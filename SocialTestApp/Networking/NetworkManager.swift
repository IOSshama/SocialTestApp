import Foundation
import Alamofire

enum NetworkError: Error {
    case invalidResponse
    case noData
    case decodingError
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://jsonplaceholder.typicode.com"
    private let localizationService = ContentLocalizationService.shared
    
    private init() {}
    
    func fetchPosts(page: Int = 1, limit: Int = 20, completion: @escaping (Result<[Post], Error>) -> Void) {
        let parameters: [String: Any] = [
            "_page": page,
            "_limit": limit
        ]
        
        AF.request("\(baseURL)/posts",
                  method: .get,
                  parameters: parameters)
            .validate()
            .responseDecodable(of: [Post].self) { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let posts):
                    // Локализуем каждый пост
                    let localizedPosts = posts.map { self.localizationService.localizePost($0) }
                    completion(.success(localizedPosts))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
} 