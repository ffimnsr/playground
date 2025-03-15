//
//  StatsManager.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Observation
import SwiftUI
import SwiftData

@Observable
class StatsManager {
    static let shared = StatsManager()

    func addEvent(context: ModelContext, type: EventType) {
        let event = Event(type: type)
        context.insert(event)
     
        do {
            try context.save()
        } catch {
            print("Error saving event: \(error.localizedDescription)")
        }
    }
}
