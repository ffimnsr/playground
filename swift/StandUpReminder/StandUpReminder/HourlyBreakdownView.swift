//
//  HourlyBreakdownView.swift
//  StandUpReminder
//
//  Created by pastel on 3/15/25.
//

import SwiftUI

struct HourlyBreakdownView: View {
    @State private var viewModel = HourlyBreakdownViewModel()

    let hours = 8

    // MARK: HourlyBreakdownView Body
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Progress")
                .font(.headline)

            HStack {
                Text("Completed")
                Spacer()
                Text("5/\(viewModel.dailyTarget) stand-ups")
            }

            ProgressView(value: 5, total: 8)

            HStack {
                ForEach(1...viewModel.dailyTarget, id: \.self) { hour in
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    hour <= 5
                                        ? Color.green : Color.gray.opacity(0.3)
                                )
                                .frame(height: 40)
                        }
                    }
                }

            }

            HStack {
                Text("\(viewModel.workingHoursStart.toStandardTime())")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.workingHoursEnd.toStandardTime())")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

@Observable
class HourlyBreakdownViewModel {
    private let settings = Settings.shared

    var dailyTarget: Int {
        settings.dailyTarget
    }

    var workingHoursStart: Int {
        settings.workingHoursStart
    }

    var workingHoursEnd: Int {
        settings.workingHoursEnd
    }
}

