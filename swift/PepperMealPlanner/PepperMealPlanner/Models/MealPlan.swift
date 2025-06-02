//
//  MealPlan.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 6/2/25.
//

import SwiftUI

struct MealPlan: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var imageUrl: String
    var recipes: [MealType: Recipe]
}
