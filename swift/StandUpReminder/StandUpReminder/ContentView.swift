//
//  ContentView.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ReminderView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Reminder")
                }
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
        }
    }
}

#Preview {
    ContentView()
}
