//
//  NotificationManager+Actions.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Foundation
import UserNotifications

extension NotificationManager {
    func setupNotificationActions() {
        // Define a "Snooze" action
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze for 5 minutes",
            options: UNNotificationActionOptions.foreground
        )

        // Define a "Done" action
        let doneAction = UNNotificationAction(
            identifier: "DONE_ACTION",
            title: "I've stood up",
            options: UNNotificationActionOptions.destructive
        )

        // Define the category that includes these actions
        let standupCategory = UNNotificationCategory(
            identifier: "STANDUP_REMINDER",
            actions: [snoozeAction, doneAction],
            intentIdentifiers: [],
            options: []
        )

        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([
            standupCategory
        ])
    }
}
