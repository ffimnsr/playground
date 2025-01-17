//
//  RecipeListView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import SwiftUI
import SwiftData
import Observation

struct RecipeListView: View {
  @Environment(\.modelContext) private var context
  @Query private var items: [Recipe]
  @State private var viewModel = ViewModel()
  
  var body: some View {
    NavigationStack {
      VStack {
        if items.isEmpty {
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
            ForEach(items) { recipe in
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
            .onDelete(perform: deleteItems)
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
//        AddRecipeView()
      }
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        context.delete(items[index])
      }
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
      .modelContainer(for: Recipe.self, inMemory: true)
  }
}
