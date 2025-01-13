//
//  RecipeItemView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import Kingfisher
import SwiftUI

struct RecipeItemView: View {
  var recipe: Recipe

  let screenBounds = UIScreen.main.bounds
  let url = URL(string: "https://placehold.co/1280x566.png")
  var body: some View {
    VStack {
      KFImage(url)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: screenBounds.width - 40, height: 250)
        .cornerRadius(10)

      HStack(spacing: 5) {
        Text(recipe.name)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(.primary)
        Spacer(minLength: 0)
        ForEach(0..<5) { index in
          Image(systemName: "star.fill")
            .foregroundStyle(.yellow)
        }
      }

      HStack {
        Text(recipe.description ?? "No description available.")
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
        Spacer(minLength: 0)
      }
    }
    .padding(.horizontal)
  }
}

#Preview {
  // Initialize a recipe
  let recipe = Recipe(
    name: "Chicken Adobo",
    imageUrl: "https://placehold.co/1280x566.png",
    description: "A Filipino dish made with chicken, soy sauce, vinegar, and garlic.",
    totalCost: 60
  )
  RecipeItemView(recipe: recipe)
}
