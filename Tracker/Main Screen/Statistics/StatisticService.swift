import Foundation

// MARK: Protocol
protocol StatisticsServiceProtocol {
    func getCompletionPercentageToday() -> Double
    func getAverageCompletionLast7Days() -> Double
    func getPerfectDaysCount() -> Int
    func getTotalCompletedTrackersCount() -> Int
}

// MARK: Struct
struct StatisticsData {
    let completionPercentageToday: Double
    let averageCompletionLast7Days: Double
    let perfectDaysCount: Int
    let totalCompletedTrackersCount: Int
    
    var hasAnyData: Bool {
        return totalCompletedTrackersCount > 0
    }
}

// MARK: Class
final class StatisticsService: StatisticsServiceProtocol {
    private let coreDataManager: CoreDataManagerProtocol
    
    init(coreDataManager: CoreDataManagerProtocol) {
            self.coreDataManager = coreDataManager
        }
    
    // MARK: Public
    func getCompletionPercentageToday() -> Double {
        let today = Date()
        let availableTrackers = getTrackersForDate(today)
        let completedTrackers = getCompletedTrackersForDate(today)
        
        guard !availableTrackers.isEmpty else {
            return 0.0
        }
        
        let percentage = Double(completedTrackers.count) / Double(availableTrackers.count)
        
        return percentage
    }
    
    func getAverageCompletionLast7Days() -> Double {
        let today = Date()
        let calendar = Calendar.current
        
        var totalPercentage: Double = 0.0
        var daysWithData = 0
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            let availableTrackers = getTrackersForDate(date)
            let completedTrackers = getCompletedTrackersForDate(date)
            
            if !availableTrackers.isEmpty {
                let dayPercentage = Double(completedTrackers.count) / Double(availableTrackers.count)
                totalPercentage += dayPercentage
                daysWithData += 1
            }
        }
        
        guard daysWithData > 0 else { return 0.0 }
        
        return totalPercentage / Double(daysWithData)
    }
    
    func getPerfectDaysCount() -> Int {
        let allRecordDates = getAllUniqueDates()
        var perfectDays = 0
        
        for date in allRecordDates {
            let availableTrackers = getTrackersForDate(date)
            let completedTrackers = getCompletedTrackersForDate(date)
            
            if !availableTrackers.isEmpty && completedTrackers.count == availableTrackers.count {
                perfectDays += 1
            }
        }
        
        return perfectDays
    }
    
    func getTotalCompletedTrackersCount() -> Int {
        return coreDataManager.trackerRecordStore.getAllRecords().count
    }
    
    // MARK: Private
    private func getTrackersForDate(_ date: Date) -> [Tracker] {
        return coreDataManager.trackerStore.getTrackersForDate(date)
    }
    
    private func getCompletedTrackersForDate(_ date: Date) -> [TrackerRecord] {
        let allCompletedRecords = coreDataManager.trackerRecordStore.getRecordsForDate(date)
        let availableTrackers = coreDataManager.trackerStore.getTrackersForDate(date)
        let availableTrackerIds = Set(availableTrackers.map { $0.id })
        
        let filteredRecords = allCompletedRecords.filter { record in
            availableTrackerIds.contains(record.id)
        }

        return filteredRecords
    }
    
    private func getAllUniqueDates() -> [Date] {
        return coreDataManager.trackerRecordStore.getAllUniqueDates()
    }
}
