//
//  Tracker.swift
//  Tracker
//
//  Created by Vadzim on 15.07.25.
//

import UIKit

struct Tracker {
    let id: String?
    let name: String?
    let color: UIColor
    let emoji: String?
    let schedule: [Int]?
    
    init(
        id: String,
        name: String,
        color: UIColor,
        emoji: String,
        schedule: [Int]?
    ){
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
