import Foundation

struct TrackerRecord {
    let id: UUID
    let date: Date
    
    init(
        id: UUID,
        date: Date
    ) {
        self.id = id
        self.date = date
    }
}
