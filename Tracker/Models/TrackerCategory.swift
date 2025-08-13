//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Vadzim on 16.07.25.
//

import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [String]?
    
    init(
        title: String,
        trackers: [String]? = nil
    ){
        self.title = title
        self.trackers = trackers
    }
}
