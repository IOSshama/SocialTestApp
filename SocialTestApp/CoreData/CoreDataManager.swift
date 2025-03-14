import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SocialTestApp")
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Posts CRUD Operations
    
    func savePosts(_ posts: [Post]) {
        posts.forEach { post in
            let fetchRequest = NSFetchRequest<PostEntity>(entityName: "PostEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %d", post.id)
            
            do {
                let results = try context.fetch(fetchRequest)
                let postEntity = results.first ?? PostEntity(context: context)
                postEntity.update(from: post)
            } catch {
                print("Error saving post: \(error)")
            }
        }
        
        saveContext()
    }
    
    func fetchPosts() -> [PostEntity] {
        let fetchRequest = NSFetchRequest<PostEntity>(entityName: "PostEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching posts: \(error)")
            return []
        }
    }
    
    func toggleLike(for postId: Int) {
        let fetchRequest = NSFetchRequest<PostEntity>(entityName: "PostEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %d", postId)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let post = results.first {
                post.isLiked = !post.isLiked
                saveContext()
            }
        } catch {
            print("Error toggling like: \(error)")
        }
    }
} 