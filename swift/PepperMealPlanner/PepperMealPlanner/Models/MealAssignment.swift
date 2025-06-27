//
//  MealAssignment.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 6/26/25.
//

import Foundation

struct MealAssignment: Identifiable {
    var id = UUID()
    var mealType: MealType
    var recipe: Recipe
}
