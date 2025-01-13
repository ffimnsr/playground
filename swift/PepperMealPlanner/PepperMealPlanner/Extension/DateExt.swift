//
//  DateExt.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import Foundation

extension Date {
  // Divide the current month dates into weeks, including previous and next month's days
  func weeksInMonth() -> [[Date]] {
    let datesInMonth = self.allDatesInMonth()
    let firstDayOfWeek = self.firstDayOfWeek()

    var weeks: [[Date]] = []
    var currentWeek: [Date] = Array(repeating: Date.distantPast, count: firstDayOfWeek)

    for date in datesInMonth {
      currentWeek.append(date)
      if currentWeek.count == 7 {
        weeks.append(currentWeek)
        currentWeek = []
      }
    }

    if !currentWeek.isEmpty {
      currentWeek.append(
        contentsOf: Array(repeating: Date.distantPast, count: 7 - currentWeek.count))
      weeks.append(currentWeek)
    }

    return weeks
  }

  // Get the first day of the month
  func startOfMonth() -> Date {
    let components = Calendar.current.dateComponents([.year, .month], from: self)
    return Calendar.current.date(from: components)!
  }

  // Get the number of days in the month
  func numberOfDaysInMonth() -> Int {
    let range = Calendar.current.range(of: .day, in: .month, for: self)!
    return range.count
  }

  // Get the day of the week for the first day of the month
  func firstDayOfWeek() -> Int {
    let components = Calendar.current.dateComponents([.year, .month], from: self)
    let firstDay = Calendar.current.date(from: components)!
    return Calendar.current.component(.weekday, from: firstDay) - 1  // Adjusting for Sunday = 1
  }

  // Get all the days of the month
  func allDatesInMonth() -> [Date] {
    let calendar = Calendar.current
    let range = calendar.range(of: .day, in: .month, for: self)!
    return range.compactMap { day -> Date? in
      var components = calendar.dateComponents([.year, .month], from: self)
      components.day = day
      return calendar.date(from: components)
    }
  }
}
