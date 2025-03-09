//
//  SettingsView.swift
//  StandUpReminder
//
//  Created by pastel on 3/5/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var settings = Settings.shared
    @State private var isWorkingHoursPickerPresented = false
    @State private var isDailyTargetPickerPresented = false
    @State private var isWeeklyGoalsPickerPresented = false

    var body: some View {
        Form {
            Section(header: Text("Reminder Settings").font(.headline)) {
                Picker("Reminder Frequency", selection: $settings.reminderFrequency) {
                    ForEach([30, 60, 90, 120], id: \.self) {
                        frequency in
                        Text("Every \(frequency) mins").tag(frequency)
                    }
                }
                .pickerStyle(.menu)

                Picker("Stand Duration", selection: $settings.standDuration) {
                    ForEach(1...10, id: \.self) {
                        duration in
                        Text("\(duration) minutes").tag(duration)
                    }
                }
                .pickerStyle(.menu)

                HStack {
                    Text("Working Hours")
                    Spacer()
                    Text("\(settings.workingHoursStart) AM - \(settings.workingHoursEnd) PM")
                        .foregroundStyle(.blue)
                }
                .onTapGesture {
                    isWorkingHoursPickerPresented.toggle()
                }
                .sheet(isPresented: $isWorkingHoursPickerPresented) {
                    VStack {
                        Text("Select Working Hours")
                            .font(.headline)
                            .padding()

                        HStack {
                            Picker("Start Time", selection: $settings.workingHoursStart)
                            {
                            ForEach(0..<settings.workingHoursEnd, id: \.self) {
                                    hour in
                                    Text("\(hour):00").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)

                            Picker("End Time", selection: $settings.workingHoursEnd) {
                                ForEach(settings.workingHoursStart + 1..<24, id: \.self)
                                { hour in
                                    Text("\(hour):00").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .padding()
                    }
                    .presentationDetents([.medium])
                }
            }

            Section(header: Text("Customization").font(.headline)) {
                Toggle("Vibration", isOn: $settings.isVibrationEnabled)
                Toggle("Sound", isOn: $settings.isSoundEnabled)
            }

            Section(header: Text("Health Goals").font(.headline)) {
                HStack {
                    Text("Daily Target")
                    Spacer()
                    Text("^[\(settings.dailyTarget) times](inflect: true)")
                        .foregroundStyle(.blue)
                }
                .onTapGesture {
                    isDailyTargetPickerPresented.toggle()
                }
                .sheet(isPresented: $isDailyTargetPickerPresented) {
                    VStack {
                        Text("Select Daily Target")
                            .font(.headline)
                            .padding()
                        Picker("", selection: $settings.dailyTarget) {
                            ForEach(1..<20, id: \.self) { target in
                                Text("\(target)").tag(target)
                            }
                        }
                        .pickerStyle(.wheel)
                        .padding()
                    }
                    .presentationDetents([.medium])
                }
                HStack {
                    Text("Weekly Goals")
                    Spacer()
                    Text("^[\(settings.weeklyGoals) day](inflect: true)")
                        .foregroundStyle(.blue)
                }
                .onTapGesture {
                    isWeeklyGoalsPickerPresented.toggle()
                }
                .sheet(isPresented: $isWeeklyGoalsPickerPresented) {
                    VStack {
                        Text("Select Weekly Goals")
                            .font(.headline)
                            .padding()

                        Picker("", selection: $settings.weeklyGoals) {
                            ForEach(1..<20, id: \.self) { goal in
                                Text("^[\(goal) day](inflect: true)").tag(goal)
                            }
                        }
                        .pickerStyle(.wheel)
                        .padding()
                    }
                    .presentationDetents([.medium])
                }
            }

            Section {
                if !notificationManager.isAuthorized {
                    Button("Enable Notifications"){
                        notificationManager.requestAuthorization()
                    }
                }
                
#if DEBUG
                Button("Test Notification") {
                    notificationManager.triggerTestNotification()
                }
#endif
                
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
