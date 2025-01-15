//
//  AddRecipeView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import SwiftUI

struct AddRecipeView: View {
  @State private var viewModel = ViewModel()
  @Environment(RecipeViewModel.self) private var recipeViewModel
  @Environment(\.dismiss) var dismiss
  
  
  let recipeTypes = ["Soup", "Main Dish", "Appetizer", "Dessert"]
  var body: some View {
    NavigationStack{
      Form {
        Section {
          TextField("Recipe Name", text: $viewModel.recipeName)
          Picker("Recipe Type", selection: $viewModel.recipeType) {
            ForEach(recipeTypes, id: \.self) {
              Text($0)
            }
          }
//          TextField(text: $viewModel.recipeDescription)
//            .frame(height: 200)
//          Picker("No. of Servings", selection: .constant(1)) {
//            ForEach(1..<10) {
//              Text("^[\($0) serving](inflect: true)")
//            }
//          }
//          TextField("Number of Servings", text: .constant(""))
//          TextField("Preparation Time", text: .constant(""))
//          TextField("Ingredients", text: .constant(""))
//          TextField("Cook Time", text: .constant(""))
//          TextField("Steps", text: .constant(""))
//          TextField("Nutritional Information", text: .constant(""))
        }
        
        Section {
          TextField("Notes", text: $viewModel.notes)
        }
      }
      .navigationTitle("Recipe Creator")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        Button("Save") {
          recipeViewModel.addRecipe(name: viewModel.recipeName, type: viewModel.recipeType)
          dismiss()
        }
      }
    }
  }
}

extension AddRecipeView {
  @Observable
  class ViewModel {
    var recipeName = ""
    var recipeType = "Soup"
    var recipeDescription = ""
    var notes = ""
  }
}

#Preview {
  VStack {
    AddRecipeView()
  }
  .environment(RecipeViewModel())
}
