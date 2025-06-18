//
//  Day.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import Foundation
import SwiftData

@Model
class DayMeals {
    var date: Date
    var meals: [MealType] = []

    init(date: Date, meals: [MealType]) {
        self.date = date
        self.meals = meals
    }

    func insertMeal(meal: MealType) {
        meals.append(meal)
    }

    func removeMeal(meal: MealType) {
        meals.removeAll { $0 == meal }
    }
}
