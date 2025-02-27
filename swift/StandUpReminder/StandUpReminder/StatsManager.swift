//
//  StatsManager.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Foundation

class StatsManager: ObservableObject {
    static let shared = StatsManager()
    
    @Published var events: [Event] {
        didSet {
            saveEvents()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "events"),
           let decodedEvents = try? JSONDecoder().decode([Event].self, from: data) {
            self.events = decodedEvents
        } else {
            self.events = []
        }
    }
    
    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: "events")
        }
    }
    
    func addEvent(type: EventType) {
        events.append(Event(date: Date(), type: type))
    }
}
