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
    var recipes: [MealAssignment] = []

    init(date: Date, recipes: [MealAssignment]) {
        self.date = date
        self.recipes = recipes
    }

    func insertMeal(meal: MealType, recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.mealType == meal }) {
            recipes[index].recipe = recipe
        } else {
            recipes.append(MealAssignment(mealType: meal, recipe: recipe))
        }
    }

    func removeMeal(meal: MealType) {
        recipes.removeAll { $0.mealType == meal }
    }
}
