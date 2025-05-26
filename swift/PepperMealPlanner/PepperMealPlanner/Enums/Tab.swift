//
//  Tab.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import Foundation

enum Tab: String, Hashable, CaseIterable {
    case home = "house.fill"
    case recipes = "book.fill"
    case planner = "calendar"
    case stats = "chart.bar.xaxis"
}
