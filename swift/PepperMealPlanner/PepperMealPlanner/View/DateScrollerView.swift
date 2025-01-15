//
//  DateScrollerView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

//import SwiftUI
//
//struct DateScrollerView: View {
//  @State var currentYearMonth = YearMonth(year: 2025, month: 1)
//  @State private var selectedDate = Date()
//  @State private var scrollIndex: Int = 0
//  
//  private var calendar: Calendar {
//    var cal = Calendar.current
//    // Adjust first weekday if needed (Sunday = 1, Monday = 2).
//    cal.firstWeekday = 1
//    return cal
//  }
// 
//  /// Provides a 2D array where each sub-array is one week of CalendarDay elements.
//  private var weeksInMonth: [[CalendarDay]] {
//    guard let baseDate = calendar.date(from: DateComponents(year: currentYearMonth.year,
//                                                            month: currentYearMonth.month))
//    else {
//      return []
//    }
//    return createWeeks(for: baseDate, in: calendar)
//  }
//
//  var body: some View {
//    VStack {
//      // Scroll horizontally between weeks using a TabView
//      TabView(selection: $scrollIndex) {
//        ForEach(weeksInMonth.indices, id: \.self) { index in
//          let week = weeksInMonth[index]
//          HStack(spacing: 15) {
//            ForEach(week, id: \.self) { calendarDay in
//              VStack {
//                // Only display day details if date is valid
//                // (Here we don't use .distantPast placeholders, we keep actual next/previous month days)
//                let dayDate = calendarDay.date
//                
//                // Show abbreviated weekday (e.g., Mon) on top
//                Text(dayDate, formatter: DateFormatter.weekdayFormatter)
//                  .font(.caption2)
//                  .foregroundColor(calendarDay.isCurrentMonth ? .primary : .gray)
//                
//                // Show day of month (e.g., 10, 31) in a small box.
//                Text(dayDate, formatter: DateFormatter.dayFormatter)
//                  .frame(width: 40, height: 40)
//                  .background(
//                    calendar.isDate(dayDate, inSameDayAs: selectedDate)
//                    ? Color.blue
//                    : Color.clear
//                  )
//                  .cornerRadius(10)
//                  .foregroundStyle(calendarDay.isCurrentMonth ? .primary : .gray)
//                  .onTapGesture {
//                    if calendarDay.isCurrentMonth {
//                      selectedDate = dayDate
//                    }
//                  }
//              }
//            }
//          }
//          .tag(index)
//        }
//      }
//      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//      .frame(maxHeight: 60)
//      .padding()
//    }
//  }
//  
//  /// Creates an array of weeks, each containing CalendarDay objects (some from adjacent months).
//  private func createWeeks(for baseDate: Date, in calendar: Calendar) -> [[CalendarDay]] {
//    var days: [CalendarDay] = []
//    
//    // 1. Identify the range of days in the current month
//    guard let monthRange = calendar.range(of: .day, in: .month, for: baseDate) else {
//      return []
//    }
//    
//    // 2. First day of the current month
//    let components = calendar.dateComponents([.year, .month], from: baseDate)
//    guard let firstOfMonth = calendar.date(from: components) else {
//      return []
//    }
//    
//    // 3. Determine which weekday the first day lands on
//    let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
//    // Number of leading placeholders (previous-month days) we should show
//    let leadingCount = (firstWeekday - calendar.firstWeekday + 7) % 7
//    
//    // 4. Fill leading days from the previous month
//    for i in 0..<leadingCount {
//      if let prevMonthDate = calendar.date(byAdding: .day, value: -leadingCount + i, to: firstOfMonth) {
//        days.append(CalendarDay(date: prevMonthDate, isCurrentMonth: false))
//      }
//    }
//    
//    // 5. Add actual days of the current month
//    for day in monthRange {
//      if let currentDate = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
//        days.append(CalendarDay(date: currentDate, isCurrentMonth: true))
//      }
//    }
//    
//    // 6. Fill trailing days (from the next month) until the week is complete
//    while days.count % 7 != 0 {
//      if let nextDate = calendar.date(byAdding: .day, value: 1, to: days.last?.date ?? baseDate) {
//        days.append(CalendarDay(date: nextDate, isCurrentMonth: false))
//      }
//    }
//    
//    // 7. Group into sub-arrays of length 7, each representing one week
//    var weeks: [[CalendarDay]] = []
//    for chunkIndex in stride(from: 0, to: days.count, by: 7) {
//      let weekChunk = Array(days[chunkIndex ..< chunkIndex + 7])
//      weeks.append(weekChunk)
//    }
//    
//    return weeks
//  }
//}
//
//#Preview {
//  DateScrollerView()
//}
