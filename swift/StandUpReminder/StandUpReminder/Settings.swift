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
    let defaults = UserDefaults.standard

    var reminderFrequency: Int {
        didSet {
            defaults.set(
                reminderFrequency, forKey: "reminderFrequency")
        }
    }

    var standDuration: Int {
        didSet {
            defaults.set(standDuration, forKey: "standDuration")
        }
    }

    var workingHoursStart: Int {
        didSet {
            defaults.set(
                workingHoursStart, forKey: "workingHoursStart")
        }
    }

    var workingHoursEnd: Int {
        didSet {
            defaults.set(
                workingHoursEnd, forKey: "workingHoursEnd")
        }
    }

    var isVibrationEnabled: Bool {
        didSet {
            defaults.set(
                isVibrationEnabled, forKey: "isVibrationEnabled")
        }
    }

    var isSoundEnabled: Bool {
        didSet {
            defaults.set(isSoundEnabled, forKey: "isSoundEnabled")
        }
    }

    var dailyTarget: Int {
        didSet {
            defaults.set(dailyTarget, forKey: "dailyTarget")
        }
    }

    var weeklyGoals: Int {
        didSet {
            defaults.set(weeklyGoals, forKey: "weeklyGoals")
        }
    }

    private init() {
        self.reminderFrequency =
            defaults.object(forKey: "reminderFrequency") as? Int
            ?? 60
        self.standDuration =
            defaults
            .object(forKey: "standDuration") as? Int ?? 1
        self.workingHoursStart =
            defaults.object(forKey: "workingHoursStart") as? Int
            ?? 9
        self.workingHoursEnd =
            defaults.object(forKey: "workingHoursEnd") as? Int
            ?? 17
        self.isVibrationEnabled =
            defaults.object(forKey: "isVibrationEnabled") as? Bool
            ?? true
        self.isSoundEnabled =
            defaults.object(forKey: "isSoundEnabled") as? Bool
            ?? true
        self.dailyTarget =
            defaults.object(forKey: "dailyTarget") as? Int ?? 8
        self.weeklyGoals =
            defaults.object(forKey: "weeklyGoals") as? Int ?? 300
    }
}
