//
//  NotificationManager+StandupReminders.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Foundation
import UserNotifications

extension NotificationManager {
    func scheduleStandUpReminders(interval: TimeInterval = 3600) {  // Default 1 hour (3600 seconds)
        // Cancel any existing notifications
        cancelStandUpReminders()

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Stand Up!"
        content.body =
            "You've been sitting for an hour. Take a short break and stretch your legs."
        content.sound = .default
        content.categoryIdentifier = "STAND_UP_REMINDER"

        // Create a repeating trigger
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: interval, repeats: true)

        // Create the request
        let request = UNNotificationRequest(
            identifier: "standUpReminder",
            content: content,
            trigger: trigger
        )

        // Add the notification request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(
                    "Error scheduling notification: \(error.localizedDescription)"
                )
            }
        }
    }

    func cancelStandUpReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["standUpReminder"])
    }
}
