//
//  Settings.swift
//  StandUpReminder
//
//  Created by pastel on 3/9/25.
//

import Combine
import Observation
import SwiftUI

@Observable
final class Settings {
    static let shared = Settings()

    var reminderFrequency: Int {
        didSet {
            UserDefaults.standard.set(
                reminderFrequency, forKey: "reminderFrequency")
        }
    }

    var standDuration: Int {
        didSet {
            UserDefaults.standard.set(standDuration, forKey: "standDuration")
        }
    }

    var workingHoursStart: Int {
        didSet {
            UserDefaults.standard.set(
                workingHoursStart, forKey: "workingHoursStart")
        }
    }

    var workingHoursEnd: Int {
        didSet {
            UserDefaults.standard.set(
                workingHoursEnd, forKey: "workingHoursEnd")
        }
    }

    var isVibrationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(
                isVibrationEnabled, forKey: "isVibrationEnabled")
        }
    }

    var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        }
    }

    var dailyTarget: Int {
        didSet {
            UserDefaults.standard.set(dailyTarget, forKey: "dailyTarget")
        }
    }

    var weeklyGoals: Int {
        didSet {
            UserDefaults.standard.set(weeklyGoals, forKey: "weeklyGoals")
        }
    }

    init() {
        self.reminderFrequency =
            UserDefaults.standard.object(forKey: "reminderFrequency") as? Int
            ?? 60
        self.standDuration =
            UserDefaults.standard
            .object(forKey: "standDuration") as? Int ?? 1
        self.workingHoursStart =
            UserDefaults.standard.object(forKey: "workingHoursStart") as? Int
            ?? 9
        self.workingHoursEnd =
            UserDefaults.standard.object(forKey: "workingHoursEnd") as? Int
            ?? 17
        self.isVibrationEnabled =
            UserDefaults.standard.object(forKey: "isVibrationEnabled") as? Bool
            ?? true
        self.isSoundEnabled =
            UserDefaults.standard.object(forKey: "isSoundEnabled") as? Bool
            ?? true
        self.dailyTarget =
            UserDefaults.standard.object(forKey: "dailyTarget") as? Int ?? 8
        self.weeklyGoals =
            UserDefaults.standard.object(forKey: "weeklyGoals") as? Int ?? 300
    }
}
