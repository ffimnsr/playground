//
//  Recipe.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import Foundation
import SwiftData

@Model
final class Recipe: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var imageUrl: String?
    var type: RecipeType?
    var ingredientPortions: [String: String]?
    var instructions: [String]?
    var briefDescription: String?
    var servings: Int?
    var nutritionalInformation: [String: String]?
    var ingredients: [String]?
    var cookingTime: Int?
    var preparationTime: Int?

    init(name: String) {
        self.name = name
    }

    init(name: String, imageUrl: String) {
        self.name = name
        self.imageUrl = imageUrl
    }

    init(name: String, briefDescription: String, imageUrl: String) {
        self.name = name
        self.briefDescription = briefDescription
        self.imageUrl = imageUrl
    }

    init(
        name: String,
        briefDescription: String,
        preparationTime: Int,
        servings: Int,
        ingredients: [String],
        instructions: [String]
    ) {
        self.name = name
        self.briefDescription = briefDescription
        self.preparationTime = preparationTime
        self.servings = servings
        self.ingredients = ingredients
        self.instructions = instructions
    }
}
