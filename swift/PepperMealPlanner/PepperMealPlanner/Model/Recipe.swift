//
//  Recipe.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import Foundation

struct Recipe: Identifiable {
  var id = UUID()
  var name: String
  var imageUrl: String
  var description: String?
  var totalCost: Double?
}

