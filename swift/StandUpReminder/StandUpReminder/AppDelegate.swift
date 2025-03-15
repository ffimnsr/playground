//
//  AppDelegate.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import SwiftUI
import UserNotifications
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate,
    UNUserNotificationCenterDelegate
{
    var modelContext: ModelContext?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // Set delegate for notification center
        UNUserNotificationCenter.current().delegate = self

        // Setup notification actions
        NotificationManager.shared.setupNotificationActions()
        
        return true
    }

    // Handle notification responses
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let context = modelContext else {
            completionHandler()
            return
        }

        // Handle different actions
        switch response.actionIdentifier {
        case "SNOOZE_ACTION":
            // Reschedule a one-time notification for 5 minutes
            let content = UNMutableNotificationContent()
            content.title = "Time to Stand Up!"
            content.body = "You snoozed your previous reminder. Stand up now!"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "STAND_UP_REMINDER"

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 5 * 60, repeats: false)
            let request = UNNotificationRequest(
                identifier: "snoozeReminder", content: content, trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
            StatsManager.shared.addEvent(context: context, type: .snooze)

        case "DONE_ACTION":
            StatsManager.shared.addEvent(context: context, type: .standUp)

        default:
            StatsManager.shared.addEvent(context: context, type: .ignore)
            break
        }

        completionHandler()
    }

    // Handle notifications when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
}
