//
//  CalendarView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()

    private var days: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.shortWeekdaySymbols
    }

    private var currentMonthDays: [Date?] {
        let calendar = Calendar.current
        let startOfMonth = selectedDate.startOfMonth()
        let numberOfDays = selectedDate.numberOfDaysInMonth()
        let firstWeekday = selectedDate.firstDayOfWeek()

        var days = [Date?]()
        for day in 0..<(numberOfDays + firstWeekday) {
            if day >= firstWeekday {
                if let date = calendar.date(
                    byAdding: .day, value: day - firstWeekday, to: startOfMonth)
                {
                    days.append(date)
                }
            } else {
                days.append(nil)  // Placeholder for empty slots
            }
        }
        return days
    }

    var body: some View {
        VStack {
            // Header with month and year
            Text("\(selectedDate, formatter: DateFormatter.monthAndYearFormatter)")
                .font(.title)
                .padding()

            // Weekday headers
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day).frame(maxWidth: .infinity)
                }
            }

            // Days grid with square aspect ratio
            GeometryReader { geometry in
                let width = geometry.size.width / 7
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(width), spacing: 0), count: 7),
                    spacing: 0
                ) {
                    ForEach(currentMonthDays.indices, id: \.self) { index in
                        if let date = currentMonthDays[index] {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .frame(width: width, height: width)
                                .background(
                                    Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                        ? Color.blue : Color.clear
                                )
                                .cornerRadius(10)
                                .onTapGesture {
                                    selectedDate = date
                                }
                        } else {
                            Text("")
                                .frame(width: width, height: width)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding()
    }
}

#Preview {
    CalendarView()
}
