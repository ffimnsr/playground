//
//  RecipeListView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import SwiftUI
import Observation

struct RecipeListView: View {
  @State private var viewModel = ViewModel()
  @State private var recipeViewModel = RecipeViewModel()
  
  var body: some View {
    NavigationStack {
      VStack {
        if recipeViewModel.items.isEmpty {
          VStack {
            Image(systemName: "tray")
              .resizable()
              .scaledToFit()
              .frame(width: 50, height: 50)
              .foregroundColor(.gray)
            Text("Recipe list is empty")
              .font(.headline)
              .foregroundColor(.gray)
              .padding(.top, 10)
          }
          .padding()
          .background(Color.gray.opacity(0.1))
          .cornerRadius(10)
          .padding()
        } else {
          List {
            ForEach(recipeViewModel.items) { recipe in
              NavigationLink(destination: {
                RecipeDetailsView()
              }) {
                HStack {
                  VStack(alignment: .leading) {
                    Text(recipe.name)
                      .font(.headline)
                    Text(recipe.type)
                      .lineLimit(1)
                  }
                  Spacer()
                  Text("35 mins")
                }
              }
            }
            .onDelete(perform: recipeViewModel.removeRecipes)
          }
        }
      }
      .navigationTitle("Recipes")
      .toolbar {
        Button("Add Recipe", systemImage: "plus") {
          viewModel.showingAddRecipe.toggle()
        }
      }
      .sheet(isPresented: $viewModel.showingAddRecipe) {
        AddRecipeView()
      }
      .environment(recipeViewModel)
    }
  }
}

extension RecipeListView {
  @Observable
  class ViewModel {
    var showingAddRecipe = false
  }
}

#Preview {
  NavigationStack {
    RecipeListView()
  }
}
