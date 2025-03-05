//
//  TimerView.swift
//  StandUpReminder
//
//  Created by pastel on 3/5/25.
//

import SwiftUI

struct TimerView: View {
    @State private var timeRemaining = 45 * 60
    @State private var isTimerRunning = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CircularTimerView(timeRemaining: timeRemaining, totalTime: 60 * 60)
                
                HourlyBreakdownView()
            }
            .padding()
        }
    }
}

struct CircularTimerView: View {
    let timeRemaining: Int
    let totalTime: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundStyle(.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(timeRemaining) / CGFloat(totalTime))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.blue)
                .rotationEffect(.degrees(270.0))
                .animation(.linear, value: timeRemaining)
            
            VStack {
                Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                Text("minutes left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct HourlyBreakdownView: View {
    let hours = 8
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hourly Breakdown")
                .font(.headline)
            
            HStack {
                ForEach(1...hours, id: \.self) { hour in
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(hour <= 5 ? Color.green : Color.gray.opacity(0.3))
                                .frame(height: 40)
                                
                            if hour <= 5 {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        Text("\(9 + hour)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}



#Preview {
    TimerView()
}
