//
//  PepperMealPlannerApp.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/10/25.
//

import SwiftData
import SwiftUI

@main
struct PepperMealPlannerApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Recipe.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
  }
}
