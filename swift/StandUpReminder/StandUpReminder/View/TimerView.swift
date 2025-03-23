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
    @State private var notificationManager = NotificationManager.shared
    @State private var settings = Settings.shared
    @State private var timeRemaining: Int = Settings.shared.reminderFrequency * 60
    @State private var showStandUpTimer = false
    @State private var isTimerRunning: Bool = true
    @State private var isStandUpMode: Bool = false
    @State private var timerCancellable: AnyCancellable?

    // MARK: TimerView Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 20) {
                        CircularTimerView(
                            timeRemaining: timeRemaining,
                            totalTime: 60 * 60
                        )
                        .frame(height: 250)

                        HStack(spacing: 20) {
                            Button(action: { toggleTimer() }) {
                                Image(
                                    systemName: isTimerRunning
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
            .onAppear(perform: startTimer)
            .onDisappear(perform: stopTimer)
            .fullScreenCover(isPresented: $showStandUpTimer) {
                StandUpTimerView(timeRemaining: timeRemaining)
            }
        }
        .onChange(of: timeRemaining) { oldValue, newValue in
            if newValue == 0 && isStandUpMode {
                showStandUpTimer = true
            }
        }
    }

    @MainActor
    func startTimer() {
        notificationManager.requestAuthorization()

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in
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

#Preview {
    TimerView()
}
