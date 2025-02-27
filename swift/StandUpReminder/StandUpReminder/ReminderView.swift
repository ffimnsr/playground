//
//  ReminderView.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import SwiftUI

struct ReminderView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isReminderActive = false
    @State private var reminderInterval = 60.0  // Default 60 minutes

    var body: some View {
        VStack(spacing: 20) {
            Text("Stand Up Reminder")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            VStack(alignment: .leading, spacing: 10) {
                Text("Remind me every")
                    .font(.headline)

                Slider(value: $reminderInterval, in: 15...120, step: 5)
                    .accentColor(.blue)
                    .padding(.horizontal)

                HStack {
                    Text("15m")
                    Spacer()
                    Text("2h")
                }
                .padding(.horizontal)

                Text("\(Int(reminderInterval)) minutes")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(10)
            .padding(.horizontal)

            Toggle("Reminders Active", isOn: $isReminderActive)
                .padding(.horizontal)
                .onChange(of: isReminderActive) { _, newValue in
                    if isReminderActive {
                        if notificationManager.isAuthorized {
                            notificationManager.scheduleStandupReminders(
                                interval: reminderInterval * 60)
                        } else {
                            notificationManager.requestAuthorization()
                            isReminderActive = false
                        }
                    } else {
                        notificationManager.cancelStandupReminders()
                    }
                }

            if !notificationManager.isAuthorized {
                Button(action: {
                    notificationManager.requestAuthorization()
                }) {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            #if DEBUG
                Button(action: {
                    notificationManager.triggerTestNotification()
                }) {
                    Text("Test Notification")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            #endif

            Spacer()

            Text(
                "Stand up regularly to improve your health and productivity"
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
        .navigationBarTitle("StandUp Reminder", displayMode: .inline)
    }
}

#Preview {
    ReminderView()
}
