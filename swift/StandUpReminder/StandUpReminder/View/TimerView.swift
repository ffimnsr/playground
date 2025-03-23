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
    @State private var showStandUpTimer = false

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
                            .foregroundColor(.brand2)
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
            .navigationTitle("Stand Up Timer")
            .onAppear(perform: viewModel.startTimer)
            .onDisappear(perform: viewModel.stopTimer)
            .fullScreenCover(isPresented: $showStandUpTimer) {
                StandUpTimerView(timeRemaining: viewModel.timeRemaining)
            }
        }
        .onChange(of: viewModel.timeRemaining) { oldValue, newValue in
            if newValue == 0 && viewModel.isStandUpMode {
                showStandUpTimer = true
            }
        }
    }
}

struct StandUpTimerView: View {
    let timeRemaining: Int
    
    var body: some View {
        VStack {
            Text("Stand Up")
                .font(.largeTitle)
                .padding()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

@Observable
class TimerViewModel {
    private let notificationManager = NotificationManager.shared
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
        notificationManager.requestAuthorization()

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateTimer()
            }
    }

    @MainActor
    private func updateTimer() {
        if timeRemaining > 0 && isTimerRunning {
            timeRemaining -= 1
        } else if timeRemaining == 0 {
            if isStandUpMode {
                startReminderTimer()
            } else {
                startStandUpTimer()
            }
        }
    }

    @MainActor
    private func startStandUpTimer() {
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

#Preview {
    TimerView()
}
