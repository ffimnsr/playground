//
//  AddRecipeView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import SwiftData
import SwiftUI

struct AddRecipeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query private var items: [Recipe]
    @State private var viewModel = ViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Recipe Name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.desc)
                    Picker("Recipe Type", selection: $viewModel.type) {
                        ForEach(RecipeType.allCases) { type in
                            Text(type.rawValue.capitalized)
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

                Section("Steps") {
                    TextEditor(text: $viewModel.steps)
                        .frame(height: 200)
                }
            }
            .navigationTitle("Recipe Creator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let recipe = Recipe(name: viewModel.name)
                        context.insert(recipe)
                        dismiss()
                    } label: {
                        Text("Create")
                            .bold()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

extension AddRecipeView {
    @Observable
    class ViewModel {
        var name = ""
        var type: RecipeType = .soup
        var desc = ""
        var steps = ""
    }
}

#Preview {
    AddRecipeView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
