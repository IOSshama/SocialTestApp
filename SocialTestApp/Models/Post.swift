import Foundation
import CoreData

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
    
    // URL для аватарки пользователя (будем использовать Lorem Picsum)
    var avatarURL: URL? {
        return URL(string: "https://picsum.photos/50/50?random=\(id)")
    }
}

// MARK: - CoreData Model
@objc(PostEntity)
public class PostEntity: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var userId: Int64
    @NSManaged public var title: String
    @NSManaged public var body: String
    @NSManaged public var isLiked: Bool
    
    func update(from post: Post) {
        self.id = Int64(post.id)
        self.userId = Int64(post.userId)
        self.title = post.title
        self.body = post.body
    }
} 