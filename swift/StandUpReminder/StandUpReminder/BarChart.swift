//
//  BarChart.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Charts
import SwiftUI

struct BarChart: View {
    let events: [Event]

    var body: some View {
        let groupedEvents = Dictionary(
            grouping: events, by: { Calendar.current.startOfDay(for: $0.date) })
        let chartData = groupedEvents.map {
            (key, value) -> (Date, Int, Int, Int) in
            let standUpCount = value.filter { $0.type == .standUp }.count
            let snoozeCount = value.filter { $0.type == .snooze }.count
            let ignoreCount = value.filter { $0.type == .ignore }.count
            return (key, standUpCount, snoozeCount, ignoreCount)
        }.sorted { $0.0 < $1.0 }

        Chart {
            ForEach(chartData, id: \.0) { data in
                BarMark(
                    x: .value("Date", data.0),
                    y: .value("Stand Up", data.1)
                )
                .foregroundStyle(.green)

                BarMark(
                    x: .value("Date", data.0),
                    y: .value("Snooze", data.2)
                )
                .foregroundStyle(.yellow)

                BarMark(
                    x: .value("Date", data.0),
                    y: .value("Ignore", data.3)
                )
                .foregroundStyle(.red)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.short))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.weekday(.short))
            }
        }
        .chartYAxis {
            AxisMarks() {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
    }
}

struct EmptyBarChart: View {
    var body: some View {
        Chart {
            ForEach(0..<7, id: \.self) { index in
                BarMark(
                    x: .value("Date", index),
                    y: .value("Count", 0)
                )
                .foregroundStyle(.gray)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: [0, 1, 2, 3, 4, 5, 6]) { value in
                AxisValueLabel {
                    Text(
                        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][
                            value.index])
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][value.index])
                }
            }
        }
        .chartYAxis {
            AxisMarks() {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
