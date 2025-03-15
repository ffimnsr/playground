//
//  StandUpRecord.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/11/25.
//

import Foundation
import SwiftData

@Model
final class StandUpRecord {
    var timestamp: Date
    var standUpCount: Int
    var standUpTarget: Int
    var completed: Bool
    
    public init(target: Int) {
        let calender = Calendar.current
        let components = calender.dateComponents([.year, .month, .day], from: .now)
        
        self.timestamp = calender.date(from: components) ?? .now
        self.standUpCount = 0
        self.standUpTarget = target
        self.completed = false
    }
}
