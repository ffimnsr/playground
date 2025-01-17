//
//  RecipeItem.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import Foundation

struct RecipeItem: Identifiable {
  var id = UUID()
  let name: String
  let type: String
}
