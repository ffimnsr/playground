//
//  Event.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Foundation
import SwiftData

@Model
final class Event {
    var timestamp: Date
    var type: EventType
    
    init(type: EventType) {
        self.timestamp = .now
        self.type = type
    }
}

enum EventType: String, Codable {
    case standUp, snooze, ignore
}
