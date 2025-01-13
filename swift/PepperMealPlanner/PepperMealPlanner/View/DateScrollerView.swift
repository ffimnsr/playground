//
//  DateScrollerView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import SwiftUI

struct DateScrollerView: View {
  @State var currentYearMonth = YearMonth(year: 2025, month: 1)
  @State private var selectedDate = Date()
  @State private var scrollIndex: Int = 0

  private var weeksInMonth: [[Date]] {
    let calendar = Calendar.current
    let components = DateComponents(year: currentYearMonth.year, month: currentYearMonth.month)
    let date = calendar.date(from: components)!
    return date.weeksInMonth()
  }

  var body: some View {
    VStack {
      // Scrollable weeks
      TabView {
        ForEach(weeksInMonth, id: \.self) { week in
          HStack(spacing: 15) {
            ForEach(week, id: \.self) { date in
              VStack {
                if date != Date.distantPast {
                  Text("\(date, formatter: DateFormatter.weekdayFormatter)")
                  Text("\(date, formatter: DateFormatter.dayFormatter)")
                    .frame(width: 40, height: 40)
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
                    .frame(width: 40, height: 40)
                }
              }
            }
          }
        }
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
      .frame(height: 100)
    }
  }
}

#Preview {
  DateScrollerView()
}
