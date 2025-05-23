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
    @Query private var recipes: [Recipe]
    @State private var viewModel = ViewModel()
    @State private var navPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView {
                VStack(spacing: 0) {
                    // Featured Recipe Card
                    FeaturedRecipeView()
                        .cornerRadius(20)
                        .padding()

                    // Recipe List Section
                    RecipeGridSection(recipes: recipes)
                }
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
        if recipes.isEmpty {
            EmptyList()
        } else {
            List {
                ForEach(recipes) { recipe in
                    Button {
                        navPath.append(recipe)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.gray.opacity(0.3))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipe.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                HStack(spacing: 8) {
                                    Label("35 mins", systemImage: "clock")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Label("2 servings", systemImage: "person.2")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
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
                context.delete(recipes[index])
            }
        }
    }
}

struct FeaturedRecipeView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            Image("recipe-placeholder")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [.black.opacity(0.5), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                }

            // Recipe Info
            VStack(alignment: .leading, spacing: 8) {
                Text("Featured Recipe")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))

                Text("Vegetarian Pizza")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("A delicious homemade pizza loaded with veggies")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
        .frame(height: 200)
    }
}

struct RecipeGridSection: View {
    let recipes: [Recipe]

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible())
            ], spacing: 16
        ) {
            ForEach(recipes) { recipe in
                RecipeCardView(recipe: recipe)
            }
        }
        .padding()
    }
}

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 12) {
            // Recipe Image
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(height: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Label("35 mins", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("2 servings", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.gray.opacity(0.1)))
        .cornerRadius(12)
    }
}

@Observable
class ViewModel {
    var showingAddRecipe = false
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)

    // Insert sample data
    let context = container.mainContext
    let sampleRecipes = [
        Recipe(name: "Vegetarian Pizza"),
        Recipe(name: "Pasta Primavera"),
        Recipe(name: "Greek Salad"),
    ]

    sampleRecipes.forEach { recipe in
        context.insert(recipe)
    }

    return RecipeListView()
        .modelContainer(container)
}
