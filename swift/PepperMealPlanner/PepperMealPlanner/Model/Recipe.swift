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
  var type: RecipeType?
  var desc: String?
  var imageUrl: String?
  var steps: String?
  var totalCost: Double?

  init(name: String) {
    self.name = name
  }

  init(name: String, imageUrl: String) {
    self.name = name
    self.imageUrl = imageUrl
  }

  init(name: String, desc: String, imageUrl: String) {
    self.name = name
    self.desc = desc
    self.imageUrl = imageUrl
  }
}
