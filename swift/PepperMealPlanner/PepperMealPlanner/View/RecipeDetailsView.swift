//
//  RecipeDetailsView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import SwiftUI

struct RecipeDetailsView: View {
  let recipe: Recipe

  var body: some View {
    Text("Recipe Details")
  }
}

#Preview {
  let recipe = Recipe(name: "Pancit Canton")
  RecipeDetailsView(recipe: recipe)
}
