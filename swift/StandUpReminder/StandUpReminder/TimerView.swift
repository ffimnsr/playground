//
//  TimerView.swift
//  StandUpReminder
//
//  Created by pastel on 3/5/25.
//

import Combine
import Observation
import SwiftUI

struct TimerView: View {
    @State private var viewModel = TimerViewModel()

    // MARK: TimerView Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 20) {
                        CircularTimerView(
                            timeRemaining: viewModel.timeRemaining,
                            totalTime: 60 * 60
                        )
                        .frame(height: 250)

                        HStack(spacing: 20) {
                            Button(action: { viewModel.toggleTimer() }) {
                                Image(
                                    systemName: viewModel.isTimerRunning
                                        ? "pause.circle.fill"
                                        : "play.circle.fill"
                                )
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                            }

                            Button(action: { /* Mark as completed */  }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }

                            Button(action: { /* Skip */  }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                        }

                        Text("Last stood up: 15 minutes ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)

                    VStack(alignment: .leading) {
                        HourlyBreakdownView()
                    }

                    HealthTipView()
                }
                .padding()
            }
            .navigationTitle("Standup Timer")
            .onAppear(perform: viewModel.startTimer)
            .onDisappear(perform: viewModel.stopTimer)
        }
    }
}

@Observable
class TimerViewModel {
    var timeRemaining: Int
    var isTimerRunning: Bool = true
    var isStandUpMode: Bool = false

    private var timerCancellable: AnyCancellable?
    private let settings = Settings.shared

    init() {
        self.timeRemaining = settings.reminderFrequency * 60
    }

    @MainActor
    func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 && self.isTimerRunning {
                    self.timeRemaining -= 1
                } else if self.timeRemaining == 0 {
                    if self.isStandUpMode {
                        self.startReminderTimer()
                    } else {
                        self.startStandupTimer()
                    }
                }
            }
    }

    @MainActor
    private func startStandupTimer() {
        isStandUpMode = true
#if DEBUG
        timeRemaining = 35
#else
        timeRemaining = settings.standDuration * 60
#endif
    }

    @MainActor
    private func startReminderTimer() {
        isStandUpMode = false
#if DEBUG
        timeRemaining = 10
#else
        timeRemaining = settings.reminderFrequency * 60
#endif
    }

    @MainActor
    func stopTimer() {
        timerCancellable?.cancel()
    }

    @MainActor
    func toggleTimer() {
        isTimerRunning.toggle()
        if isTimerRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }
}

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

//                            if hour <= 5 {
//                                Image(systemName: "checkmark")
//                                    .foregroundStyle(.white)
//                            }
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

struct HealthTipView: View {
    @State private var healthTips: [HealthTip] = []

    // MARK: HealthTipView Body
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
                .font(.title)

            VStack(alignment: .leading, spacing: 5) {
                Text("Health Tip")
                    .font(.headline)

                if healthTips.isEmpty {
                    Text(
                        "Standing for just 3 minutes every hour can reduce the negative health effects of prolonged sitting."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else {
                    Text(healthTips.first?.description ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button("Learn more") {
                    // Do something here
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }
            .onAppear {
                MockHealthTipAPI.shared.fetchHealthTips { tips in
                    healthTips = tips
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    TimerView()
}
