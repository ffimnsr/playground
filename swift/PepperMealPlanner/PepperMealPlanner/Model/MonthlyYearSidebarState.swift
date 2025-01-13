//
//  MonthlyYearSidebarState.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import SwiftUI
import Observation

@Observable
class MonthlyYearSidebarState {
  var monthYear1Component: DateComponents = .init()
  var monthYear2Component: DateComponents = .init()
  var monthYear1Offset: CGFloat = .zero
  var monthYear2Offset: CGFloat = screen.height + 100
  
  private var isMonthYear1Active: Bool {
    monthYear1Offset < monthYear2Offset
  }
  
  
}
