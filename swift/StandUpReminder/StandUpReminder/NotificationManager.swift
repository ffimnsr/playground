//
//  NotificationManager.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    init() {
        checkAuthorization()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .badge, .sound,
        ]) { granted, error in
            DispatchQueue.main.async {
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
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
}
