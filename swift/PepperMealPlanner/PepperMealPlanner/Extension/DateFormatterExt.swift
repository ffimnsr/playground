//
//  DateFormatter-Ext.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import Foundation

extension DateFormatter {
  static var monthAndYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
  }

  static var monthNameFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    return formatter
  }

  static var dayFormatter: DateFormatter {
    let formatter = DateFormatter()
    // Day of month (.e.g., 1 to 31)
    formatter.dateFormat = "d"
    return formatter
  }
  
  static var yearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter
  }

  static var weekdayFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    return formatter
  }
}
