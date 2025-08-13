//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Vadzim on 16.07.25.
//

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
