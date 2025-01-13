//
//  MonthlyYearSidebarView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import SwiftUI

struct MonthlyYearSidebarView: View {
  @State private var size1: CGSize = .zero
  @State private var size2: CGSize = .zero
  
  @State var state: MonthlyYearSidebarState
  
  private var offset1: CGFloat {
  }
  
  private var offset2: CGFloat {
  }
  
  var monthYear1Text: some View {
    Text(monthYear1FullMonthWithYear.uppercased())
      .tracking(10)
      .foregroundColor(isMonthYear1SameMonthAndYearAsToday ? appTheme.primary : nil)
      .font(.caption)
      .fontWeight(.semibold)
      .lineLimit(1)
      .padding(.vertical, 8)
      .transition(.opacity)
  }
  
  var isMonthYear1SameMonthAndYearAsToday: Bool {
    appCalendar.isDate(state.monthYear1Component.date, equalTo: Date(), toGranularity: .month) &&
    appCalendar.isDate(state.monthYear1Component.date, equalTo: Date(), toGranularity: .year)
  }
  
  var monthYear1FullMonthWithYear: String {
    state.monthYear1Component.date.fullMonthWithYear
  }
  
  var monthYear2Text: some View {
    Text(monthYear2FullMonthWithYear.uppercased())
      .tracking(10)
      .foregroundColor(isMonthYear2SameMonthAndYearAsToday ? appTheme.primary : nil)
      .font(.caption)
      .fontWeight(.semibold)
      .lineLimit(1)
      .padding(.vertical, 8)
      .transition(.opacity)
  }
  
  var isMonthYear2SameMonthAndYearAsToday: Bool {
    appCalendar.isDate(state.monthYear2Component.date, equalTo: Date(), toGranularity: .month) &&
    appCalendar.isDate(state.monthYear2Component.date, equalTo: Date(), toGranularity: .year)
  }
  
  var monthYear2FullMonthWithYear: String {
    state.monthYear2Component.date.fullMonthWithYear
  }
  
  var body: some View {
    ZStack(alignment: .top) {
      
    }
  }
}
