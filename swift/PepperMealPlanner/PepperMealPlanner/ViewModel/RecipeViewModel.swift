//
//  RecipeViewModel.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import Observation
import SwiftUI

@Observable
class RecipeViewModel {
  var items = [RecipeItem]()
  
  func addRecipe(name: String, type: String) {
    let recipe = RecipeItem(name: name, type: type)
    items.append(recipe)
  }
  
  func removeRecipes(at indexSet: IndexSet) {
    items.remove(atOffsets: indexSet)
  }
}
