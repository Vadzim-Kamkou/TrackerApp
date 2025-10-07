import Foundation

enum TrackerFilter: Int, CaseIterable {
    case allTrackers = 0
    case todayTrackers = 1
    case completedTrackers = 2
    case uncompletedTrackers = 3
    
    var title: String {
        switch self {
        case .allTrackers:
            return NSLocalizedString("filter_all_trackers", comment: "All trackers filter")
        case .todayTrackers:
            return NSLocalizedString("filter_today_trackers", comment: "Today trackers filter")
        case .completedTrackers:
            return NSLocalizedString("filter_completed_trackers", comment: "Completed trackers filter")
        case .uncompletedTrackers:
            return NSLocalizedString("filter_uncompleted_trackers", comment: "Uncompleted trackers filter")
        }
    }
    
    var shouldShowCheckmark: Bool {
        switch self {
        case .allTrackers, .todayTrackers:
            return false
        case .completedTrackers, .uncompletedTrackers:
            return true
        }
    }
    
    var setsCurrentDate: Bool {
        return self == .todayTrackers
    }
    
    var isActiveFilter: Bool {
        switch self {
        case .allTrackers, .todayTrackers:
            return false
        case .completedTrackers, .uncompletedTrackers:
            return true
        }
    }
}
