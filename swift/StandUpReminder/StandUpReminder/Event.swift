//
//  Event.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Foundation

struct Event: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let type: EventType
}

enum EventType: String, Codable {
    case standUp, snooze, ignore
}
