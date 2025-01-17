//
//  RecipeType.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/17/25.
//

import Foundation

enum RecipeType: String, CaseIterable, Identifiable, Codable {
  case soup = "soup"
  case mainDish = "main"
  case sideDish = "side"
  case appetizer = "appetizer"
  case dessert = "dessert"
  var id: Self { self }
}
