import Foundation

// MARK: - Protocol
protocol CategoryViewModelProtocol {
    var categories: [TrackerCategory] { get }
    var onCategoriesUpdated: (() -> Void)? { get set }
    var onEmptyStateChanged: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func loadCategories()
    func selectCategory(at index: Int)
    func addCategory(_ category: TrackerCategory)
    func getSelectedIndex() -> Int?
    func setPreselectedCategory(title: String?)
    func getCategoryTitle(at index: Int) -> String
    func isSelected(at index: Int) -> Bool
    func getCategoriesCount() -> Int
    func getSelectedCategory() -> TrackerCategory?
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    // MARK: - Properties
    private let trackerCategoryStore: TrackerCategoryStore?
    private var _categories: [TrackerCategory] = []
    private var selectedIndex: Int?
    private var preselectedTitle: String?
    
    // MARK: - Bindings (замыкания для связи с View)
    var onCategoriesUpdated: (() -> Void)?
    var onEmptyStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Computed Properties
    var categories: [TrackerCategory] {
        return _categories
    }
    
    // MARK: - Init
    init(trackerCategoryStore: TrackerCategoryStore?) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        guard let trackerCategoryStore = trackerCategoryStore else {
            onError?("TrackerCategoryStore недоступен")
            return
        }
        
        do {
            let loadedCategories = try trackerCategoryStore.fetchTrackerCategory()
            _categories = loadedCategories
            
            if let title = preselectedTitle {
                selectedIndex = _categories.firstIndex { $0.title == title }
            }
            
            onCategoriesUpdated?()
            onEmptyStateChanged?(_categories.isEmpty)
            
            print("Загружено \(_categories.count) категорий")
        } catch {
            onError?("Ошибка загрузки категорий: \(error.localizedDescription)")
        }
    }
    
    func selectCategory(at index: Int) {
        guard index < _categories.count else { return }
        selectedIndex = index
        onCategoriesUpdated?()
    }
    
    func addCategory(_ category: TrackerCategory) {
        _categories.append(category)
        selectedIndex = _categories.count - 1
        
        onCategoriesUpdated?()
        onEmptyStateChanged?(_categories.isEmpty)
    }
    
    func getSelectedIndex() -> Int? {
        return selectedIndex
    }
    
    func setPreselectedCategory(title: String?) {
        preselectedTitle = title
    }
    
    func getCategoryTitle(at index: Int) -> String {
        guard index < _categories.count else { return "" }
        return _categories[index].title
    }
    
    func isSelected(at index: Int) -> Bool {
        return selectedIndex == index
    }
    
    func getCategoriesCount() -> Int {
        return _categories.count
    }
    
    func getSelectedCategory() -> TrackerCategory? {
        guard let index = selectedIndex, index < _categories.count else { return nil }
        return _categories[index]
    }
}
