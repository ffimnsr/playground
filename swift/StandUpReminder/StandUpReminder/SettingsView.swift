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
    @State private var isWorkingHoursPickerPresented = false
    @State private var isDailyTargetPickerPresented = false
    @State private var isWeeklyGoalsPickerPresented = false
    
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
                            Picker("Start Time", selection: $workingHoursStart) {
                                ForEach(0..<workingHoursEnd, id: \.self) { hour in
                                    Text("\(hour):00").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            
                            Picker("End Time", selection: $workingHoursEnd) {
                                ForEach(workingHoursStart+1..<24, id: \.self) { hour in
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
                Toggle("Vibration", isOn: $isVibrationEnabled)
                Toggle("Sound", isOn: $isSoundEnabled)
                Toggle("Dark Mode", isOn: $isDarkModeEnabled)
            }
            
            Section(header: Text("Health Goals").font(.headline)) {
                HStack {
                    Text("Daily Target")
                    Spacer()
                    Text("^[\(dailyTarget) times](inflect: true)")
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
                        Picker("", selection: $dailyTarget) {
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
                    Text("^[\(weeklyGoals) day](inflect: true)")
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
                        
                        Picker("", selection: $weeklyGoals) {
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
