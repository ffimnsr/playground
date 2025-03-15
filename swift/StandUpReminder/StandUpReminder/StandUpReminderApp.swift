//
//  StandUpReminderApp.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import SwiftUI
import SwiftData

@main
struct StandUpReminderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                StandUpRecord.self,
                Event.self,
            ])
            container = try ModelContainer(for: schema)
            appDelegate.modelContext = container.mainContext
        } catch {
            fatalError("Unable to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
