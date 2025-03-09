//
//  StatsView.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import SwiftUI

struct StatsView: View {
    @State private var statsManager = StatsManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                WeeklySummaryView()
                MonthlyStreakView()
            }
            .padding()
        }
    }
}

struct WeeklySummaryView: View {
    let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let values = [75, 90, 60, 85, 70, 40, 65] // Example values

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Summary")
                .font(.headline)
            
            Text("Your standing activity for the past 7 days.")
                .font(.subheadline)
                
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7) { index in
                    VStack {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 42, height: CGFloat(values[index]))
                        Text(weekDays[index])
                            .font(.caption)
                    }
                }
            }
            .frame(height: 200)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Weekly Average")
                        .font(.headline)
                    Text("6.2/8")
                        .font(.title)
                    Text("stand-ups per day")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Best Day")
                        .font(.headline)
                    Text("Tuesday")
                        .font(.title)
                    Text("90% completion")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }
            
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

struct MonthlyStreakView: View {
    let daysInMonth: Int = 30
    let successfulDays = [
        1, 2, 3, 5, 6, 7, 8, 9, 10, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 24,
        26, 27, 28, 29, 30,
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Monthly Streak")
                .font(.headline)

            Text("Days with at least 5 stand-ups")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 5), count: 7),
                spacing: 5
            ) {
                ForEach(1...daysInMonth, id: \.self) { day in
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                successfulDays.contains(day)
                                    ? Color.green : Color.secondary.opacity(0.3)
                            )
                            .aspectRatio(1, contentMode: .fit)
                        Text("\(day)")
                            .font(.caption2)
                            .foregroundStyle(
                                successfulDays.contains(day)
                                    ? Color.white : Color.primary)
                    }
                }
            }

            Text("Current Streak: 5 days")
                .font(.headline)
                .padding(.vertical)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    StatsView()
}
