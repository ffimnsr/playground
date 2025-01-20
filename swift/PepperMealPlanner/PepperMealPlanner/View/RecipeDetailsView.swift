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
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Header Image
        Rectangle()
          .fill(Color.gray.opacity(0.2))
          .frame(height: 250)
          .overlay {
            Image(systemName: "photo")
              .font(.largeTitle)
              .foregroundColor(.gray)
          }
        
        VStack(alignment: .leading, spacing: 16) {
          // Recipe Title and Meta
          VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name)
              .font(.title)
              .fontWeight(.bold)
            
            HStack(spacing: 16) {
              Label("35 mins", systemImage: "clock")
              Label("2 servings", systemImage: "person.2")
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
          }
          
          // Ingredients Section
          VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
              .font(.headline)
            
            ForEach(recipe.ingredients ?? [], id: \.self) { ingredient in
              HStack {
                Image(systemName: "circle.fill")
                  .font(.system(size: 6))
                Text(ingredient)
              }
              .foregroundColor(.secondary)
            }
          }
          
          // Instructions Section
          VStack(alignment: .leading, spacing: 8) {
            Text("Instructions")
              .font(.headline)
            
            ForEach(Array(recipe.instructions?.enumerated() ?? [].enumerated()),
                    id: \.element) { index, step in
              HStack(alignment: .top) {
                Text("\(index + 1).")
                  .fontWeight(.bold)
                Text(step)
              }
              .padding(.vertical, 4)
              .foregroundColor(.secondary)
            }
          }
        }
        .padding()
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    let recipe = Recipe(
      name: "Pancit Canton",
      preparationTime: 30,
      servings: 4,
      ingredients: [
        "500g canton noodles",
        "200g chicken breast, sliced",
        "2 carrots, julienned",
        "1 cabbage, chopped",
        "3 cloves garlic, minced"
      ],
      instructions: [
        "Soak noodles in warm water for 10 minutes",
        "Sauté garlic and chicken until golden brown",
        "Add vegetables and stir-fry for 3 minutes",
        "Add noodles and seasoning",
        "Cook until noodles are tender"
      ]
    )
    
    RecipeDetailsView(recipe: recipe)
  }
}
