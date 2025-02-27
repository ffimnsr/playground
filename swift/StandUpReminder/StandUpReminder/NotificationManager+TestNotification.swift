//
//  NotificationManager+TestNotification.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Foundation
import UserNotifications

extension NotificationManager {
    func triggerTestNotification() {
        // Create test notification content
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body =
            "This is a test notification to ensure everything is working correctly."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "TEST_NOTIFICATION"

        // Create an immediate trigger
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1, repeats: false)

        // Create the request
        let request = UNNotificationRequest(
            identifier: "testNotification",
            content: content,
            trigger: trigger
        )

        // Add the notification request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(
                    "Error triggering test notification: \(error.localizedDescription)"
                )
            }
        }
    }
}
