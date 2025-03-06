//
//  StatsView.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import SwiftUI

struct StatsView: View {
    @StateObject private var statsManager = StatsManager.shared

    var body: some View {
        VStack {
            Text("Stand Up Stats")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            if statsManager.events.isEmpty {
                EmptyBarChart()
                    .frame(height: 300)
                    .padding()
            } else {
                BarChart(events: statsManager.events)
                    .frame(height: 300)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Stats", displayMode: .inline)
    }
}

struct MonthlyStreakView: View {
    let daysInMonth: Int = 30
    let successfulDays = [1, 2, 3, 5, 6, 7, 8, 9, 10, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 24, 26, 27, 28, 29, 30]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Monthly Streak")
                .font(.headline)
            
        }
    }
}

#Preview {
    StatsView()
}
