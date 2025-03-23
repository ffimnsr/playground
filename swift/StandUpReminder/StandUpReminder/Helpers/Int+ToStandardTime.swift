//
//  Int+ToStandardTime.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/11/25.
//

import Foundation

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h a"
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

extension Int {
    func toStandardTime() -> String {
        // Validate input
        guard self >= 0 && self <= 23 else {
            return "Invalid hour format"
        }

        let date = Calendar.current.date(from: DateComponents(hour: self)) ?? Date()
        return timeFormatter.string(from: date)
    }
}
