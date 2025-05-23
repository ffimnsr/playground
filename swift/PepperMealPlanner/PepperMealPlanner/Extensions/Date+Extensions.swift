//
//  DateExt.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import Foundation

extension Date {
    /// Gives the current week dates
    static var currentWeek: [Day] {
        let calendar = Calendar.current
        guard let firstWeekday = calendar.dateInterval(of: .weekOfMonth, for: .now)?.start else {
            return []
        }
        
        var week: [Day] = []
        for index in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: index, to: firstWeekday) {
                week.append(.init(date: day))
            }
        }
        
        return week
    }
    
    /// Convert date to string in the given format
    func string(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    /// Check if both dates are the same
    func isSame(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    struct Day: Identifiable {
        var id: String = UUID().uuidString
        var date: Date
    }
    
    /// Returns all weeks (array of date arrays) in the same month as this date.
    /// Each inner array represents a single week.
    /// Placeholders can be set to Date.distantPast for days not in the month (otherwise optional could be used).
    func weeksInMonth() -> [[Date]] {
        var calendar = Calendar.current
        // Ensure consistent week start (e.g., Sunday or Monday)
        calendar.firstWeekday = 1  // Sunday = 1, Monday = 2
                                   // Calculate the range of days in this month
        guard let monthRange = calendar.range(of: .day, in: .month, for: self)
        else {
            return []
        }
        
        // Create a 2D array, each sub-array is a single week
        var weeks: [[Date]] = []
        var currentWeek: [Date] = []
        
        // Find the first day of the month
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let firstOfMonth = calendar.date(from: components) else {
            return []
        }
        
        // Fill in "leading" days not in the month
        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        // Example: if first day is Wednesday (weekday=4) and Sunday is first
        // weekday=1, we need 3 placeholders (4 - 1).
        let placeholdersCount = weekdayOfFirst - calendar.firstWeekday
        for _ in 0..<placeholdersCount {
            currentWeek.append(.distantPast)
        }
        
        // Fill in actual days of the month
        for day in monthRange {
            guard
                let date = calendar.date(
                    byAdding: .day, value: day - 1, to: firstOfMonth)
            else {
                continue
            }
            
            currentWeek.append(date)
            // If a week is complete (7 days), append it
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek.removeAll()
            }
        }
        
        // Fill remaining slots in the last week with placeholders if needed
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(.distantPast)
            }
            weeks.append(currentWeek)
        }
        
        return weeks
    }
    
    // Get the first day of the month
    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents(
            [.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
    
    // Get the number of days in the month
    func numberOfDaysInMonth() -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: self)!
        return range.count
    }
    
    // Get the day of the week for the first day of the month
    func firstDayOfWeek() -> Int {
        let components = Calendar.current.dateComponents(
            [.year, .month], from: self)
        let firstDay = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: firstDay) - 1  // Adjusting for Sunday = 1
    }
    
    // Get all the days of the month
    func allDatesInMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        return range.compactMap { day -> Date? in
            var components = calendar.dateComponents(
                [.year, .month], from: self)
            components.day = day
            return calendar.date(from: components)
        }
    }
}
