import Foundation

// MARK: - Protocol
protocol TrackerSearchServiceProtocol {
    var searchText: String { get }
    var isSearchActive: Bool { get }
    var onSearchResultsUpdated: (() -> Void)? { get set }
    
    func updateSearchText(_ text: String)
    func updateCategories(_ categories: [TrackerCategory])
    func clearSearch()
    func getSearchResults(from categories: [TrackerCategory], ignoreSchedule: Bool) -> [TrackerCategory]
}

// MARK: - Implementation
final class TrackerSearchService: TrackerSearchServiceProtocol {
    
    // MARK: - Properties
    private(set) var searchText: String = ""
    private var allCategories: [TrackerCategory] = []
    
    var isSearchActive: Bool {
        return !searchText.isEmpty
    }
    
    var onSearchResultsUpdated: (() -> Void)?
    
    // MARK: - Public
    func updateSearchText(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard searchText != trimmedText else { return }
        
        searchText = trimmedText
        onSearchResultsUpdated?()
    }
    
    func updateCategories(_ categories: [TrackerCategory]) {
        allCategories = categories
        onSearchResultsUpdated?()
    }
    
    func clearSearch() {
        searchText = ""
        onSearchResultsUpdated?()
    }
    
    func getSearchResults(from categories: [TrackerCategory], ignoreSchedule: Bool = false) -> [TrackerCategory] {
        guard isSearchActive else {
            return categories
        }
        
        let results: [TrackerCategory] = allCategories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matches = tracker.name.localizedCaseInsensitiveContains(searchText)
                return matches
            }
            
            if filteredTrackers.isEmpty {
                return nil
            } else {
                return TrackerCategory(
                    title: category.title,
                    trackers: filteredTrackers
                )
            }
        }
        
        return results
    }
}
