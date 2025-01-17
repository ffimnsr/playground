//
//  RecipeListView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import Observation
import SwiftData
import SwiftUI

struct RecipeListView: View {
  @Environment(\.modelContext) private var context
  @Query private var items: [Recipe]
  @State private var viewModel = ViewModel()
  @State private var navPath = NavigationPath()

  var body: some View {
    NavigationStack(path: $navPath) {
      VStack {
        recipeList
      }
      .navigationTitle("Recipes")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem {
          Button("Add Recipe", systemImage: "plus") {
            viewModel.showingAddRecipe.toggle()
          }
        }
      }
      .sheet(isPresented: $viewModel.showingAddRecipe) {
        AddRecipeView()
      }
    }
  }

  @ViewBuilder var recipeList: some View {
    if items.isEmpty {
      EmptyList()
    } else {
      List {
        ForEach(items) { recipe in
          Button {
            navPath.append(recipe)
          } label: {
            HStack {
              VStack(alignment: .leading) {
                Text(recipe.name)
                  .font(.headline)
                Text("Hello")
                  .lineLimit(1)
              }
              Spacer()
              Text("35 mins")
            }
          }
          .buttonStyle(.plain)
        }
        .onDelete(perform: deleteItems)
      }
      .navigationDestination(for: Recipe.self) { recipe in
        RecipeDetailsView(recipe: recipe)
      }
    }
  }

  func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        context.delete(items[index])
      }
    }
  }
}

@Observable
class ViewModel {
  var showingAddRecipe = false
}

#Preview {
  RecipeListView()
    .modelContainer(for: Recipe.self, inMemory: true)
}
