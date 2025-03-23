//
//  CircularTimerView.swift
//  StandUpReminder
//
//  Created by pastel on 3/15/25.
//

import SwiftUI

struct CircularTimerView: View {
    let timeRemaining: Int
    let totalTime: Int

    // MARK: CircularTimerView Body
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundStyle(.blue)

            Circle()
                .trim(
                    from: 0.0, to: CGFloat(timeRemaining) / CGFloat(totalTime)
                )
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 20, lineCap: .round, lineJoin: .round)
                )
                .foregroundStyle(.blue)
                .rotationEffect(.degrees(270.0))
                .animation(.linear, value: timeRemaining)

            VStack {
                Text(
                    "\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))"
                )
                .font(.system(size: 50, weight: .bold, design: .rounded))

                Text("minutes left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
