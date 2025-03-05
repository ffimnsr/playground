//
//  SettingsView.swift
//  StandUpReminder
//
//  Created by pastel on 3/5/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var reminderFrequency = 60
    @State private var standDuration = 3
    @State private var workingHoursStart = 9
    @State private var workingHoursEnd = 17
    @State private var isVibrationEnabled = true
    @State private var isSoundEnabled = true
    @State private var isDarkModeEnabled = false
    @State private var dailyTarget = 8
    @State private var weeklyGoals = 5
    
    var body: some View {
        Form {
            Section(header: Text("Reminder Settings").font(.headline)) {
                Picker("Reminder Frequency", selection: $reminderFrequency) {
                    ForEach([30, 60, 90, 120], id: \.self) {
                        frequency in
                        Text("Every \(frequency) mins").tag(frequency)
                    }
                }
                .pickerStyle(.menu)
                
                Picker("Stand Duration", selection: $standDuration) {
                    ForEach(1...10, id: \.self) {
                        duration in
                        Text("\(duration) minutes").tag(duration)
                    }
                }
                .pickerStyle(.menu)
                
                HStack {
                    Text("Working Hours")
                    Spacer()
                    Text("\(workingHoursStart) AM - \(workingHoursEnd) PM")
                    Stepper("", onIncrement: {
                        if workingHoursEnd < 23 { workingHoursEnd += 1 }
                    }, onDecrement: {
                        if workingHoursStart > 0 { workingHoursStart -= 1 }
                    })
                }
            }
            
            Section(header: Text("Customization").font(.headline)) {
                Toggle("Vibration", isOn: $isVibrationEnabled)
                Toggle("Sound", isOn: $isSoundEnabled)
                Toggle("Dark Mode", isOn: $isDarkModeEnabled)
            }
            
            Section(header: Text("Health Goals").font(.headline)) {
                Stepper("Daily Target: \(dailyTarget) times", value: $dailyTarget, in: 1...20)
                Stepper("Weekly Goals: \(weeklyGoals) days", value: $weeklyGoals, in: 1...7)
            }
            
            Section {
                Button("Reset All Settings") {
                }
                .foregroundStyle(.red)
            }
        }
    }
}


#Preview {
    SettingsView()
}
