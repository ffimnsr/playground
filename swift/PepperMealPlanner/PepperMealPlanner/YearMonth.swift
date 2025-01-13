//
//  YearMonth.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import Foundation

struct YearMonth: Equatable, Hashable {
  var year: Int
  var month: Int

  var monthName: String {
    let dateFormatter = DateFormatter.monthNameFormatter
    let components = DateComponents(year: self.year, month: self.month)
    let date = Calendar.current.date(from: components)!
    return dateFormatter.string(from: date)
  }

  func increment(by months: Int) -> YearMonth {
    let calendar = Calendar.current
    let date = calendar.date(from: DateComponents(year: self.year, month: self.month))!
    let newDate = calendar.date(byAdding: .month, value: months, to: date)!
    let newComponents = calendar.dateComponents([.year, .month], from: newDate)
    return YearMonth(year: newComponents.year!, month: newComponents.month!)
  }

  func toDate() -> Date {
    let calendar = Calendar.current
    return calendar.date(from: DateComponents(year: self.year, month: self.month))!
  }
}
