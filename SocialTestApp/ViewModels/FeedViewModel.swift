import Foundation

class FeedViewModel {
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMoreData = true
    
    var posts: [PostEntity] = []
    
    // Замыкания для обновления UI
    var onPostsUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    func loadInitialPosts() {
        loadPosts(isRefreshing: true)
    }
    
    func refreshPosts() {
        currentPage = 1
        hasMoreData = true
        loadPosts(isRefreshing: true)
    }
    
    func loadMorePosts() {
        guard !isLoading, hasMoreData else { return }
        currentPage += 1
        loadPosts(isRefreshing: false)
    }
    
    private func loadPosts(isRefreshing: Bool) {
        isLoading = true
        onLoadingStateChanged?(true)
        
        networkManager.fetchPosts(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            self.onLoadingStateChanged?(false)
            
            switch result {
            case .success(let newPosts):
                if isRefreshing {
                    // Если обновляем, очищаем старые данные
                    self.posts.removeAll()
                }
                
                // Сохраняем посты в CoreData
                self.coreDataManager.savePosts(newPosts)
                
                // Загружаем обновленные данные из CoreData
                self.posts = self.coreDataManager.fetchPosts()
                self.hasMoreData = !newPosts.isEmpty
                self.onPostsUpdated?()
                
            case .failure(let error):
                if self.posts.isEmpty {
                    // Если нет данных, пробуем загрузить из CoreData
                    self.posts = self.coreDataManager.fetchPosts()
                    self.onPostsUpdated?()
                }
                self.onError?(error)
            }
        }
    }
    
    func toggleLike(for postId: Int) {
        coreDataManager.toggleLike(for: postId)
        posts = coreDataManager.fetchPosts()
        onPostsUpdated?()
    }
} 