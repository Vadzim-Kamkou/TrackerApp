import Foundation

protocol StatisticsServiceProtocol {
    func getCompletionPercentageToday() -> Double
    func getAverageCompletionLast7Days() -> Double
    func getPerfectDaysCount() -> Int
    func getTotalCompletedTrackersCount() -> Int
}

struct StatisticsData {
    let completionPercentageToday: Double
    let averageCompletionLast7Days: Double
    let perfectDaysCount: Int
    let totalCompletedTrackersCount: Int
    
    var hasAnyData: Bool {
        return totalCompletedTrackersCount > 0
    }
}


class StatisticsService: StatisticsServiceProtocol {
    private let coreDataManager: CoreDataManagerProtocol
    
    init(coreDataManager: CoreDataManagerProtocol) {
            self.coreDataManager = coreDataManager
        }
    
    // 1. % Выполнено сегодня
    func getCompletionPercentageToday() -> Double {
        let today = Date()
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: today)
        
        print("🔍 ДЕТАЛЬНАЯ ДИАГНОСТИКА СТАТИСТИКИ СЕГОДНЯ:")
        print("   Сегодня: \(DateFormatter.localizedString(from: today, dateStyle: .medium, timeStyle: .short))")
        print("   День недели: \(todayWeekday) (1=Вс, 2=Пн, 3=Вт, 4=Ср, 5=Чт, 6=Пт, 7=Сб)")
        
        let availableTrackers = getTrackersForDate(today)
        let completedTrackers = getCompletedTrackersForDate(today) // Теперь уже отфильтрованные
        
        print("   📋 ДОСТУПНЫЕ ТРЕКЕРЫ (\(availableTrackers.count)):")
        for (index, tracker) in availableTrackers.enumerated() {
            print("      \(index + 1). \(tracker.name)")
            print("         ID: \(tracker.id)")
            if let schedule = tracker.schedule {
                print("         Расписание: \(schedule) (содержит \(todayWeekday)? \(schedule.contains(todayWeekday)))")
            } else {
                print("         Расписание: нет (нерегулярное событие)")
            }
        }
        
        print("   ✅ ВЫПОЛНЕННЫЕ ТРЕКЕРЫ (\(completedTrackers.count)):")
        for (index, record) in completedTrackers.enumerated() {
            print("      \(index + 1). ID: \(record.id)")
            print("         Дата: \(DateFormatter.localizedString(from: record.date, dateStyle: .medium, timeStyle: .short))")
            
            // Теперь все записи должны быть доступными
            let isAvailable = availableTrackers.contains { $0.id == record.id }
            print("         Доступен сегодня? \(isAvailable)")
        }
        
        guard !availableTrackers.isEmpty else {
            print("   ❌ Результат: 0% (нет доступных трекеров)")
            return 0.0
        }
        
        let percentage = Double(completedTrackers.count) / Double(availableTrackers.count)
        print("   📊 РАСЧЕТ: \(completedTrackers.count) / \(availableTrackers.count) = \(percentage)")
        print("   📊 Результат: \(Int(percentage * 100))%")
        
        return percentage
    }
    
    // 2. % Среднее за 7 дней
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
    

    // 3. Идеальные дни
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
    
    // 4. Всего завершено
    func getTotalCompletedTrackersCount() -> Int {
        return coreDataManager.trackerRecordStore.getAllRecords().count
    }
    
    // MARK: Private Functions
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
