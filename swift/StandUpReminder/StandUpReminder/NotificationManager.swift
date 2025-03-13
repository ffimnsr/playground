//
//  NotificationManager.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Foundation
import UserNotifications
import Observation

@Observable
class NotificationManager {
    static let shared = NotificationManager()

    var isAuthorized = false

    init() {
        checkAuthorization()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .badge, .sound,
        ]) { granted, error in
            Task { @MainActor in
                self.isAuthorized = granted
            }

            if let error = error {
                print(
                    "Error requesting notification authorization: \(error.localizedDescription)"
                )
            }
        }
    }

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
}
