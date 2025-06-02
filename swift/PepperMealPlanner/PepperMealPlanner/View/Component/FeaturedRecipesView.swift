//
//  FeaturedRecipesView.swift
//  PepperMealPlanner
//
//  Created on 6/2/25.
//

import SwiftUI

struct FeaturedRecipesView: View {
    @State private var featuredRecipes: [Recipe] = []

    var body: some View {
        VStack(spacing: 0) {
            Text("Featured Recipes")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(featuredRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                            RecipeItemView(recipe: recipe)
                                .frame(width: UIScreen.main.bounds.width - 40)
                        }
                        .buttonStyle(PlainButtonStyle()) // Prevents navigation link styling
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 10)
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 16)
        }
        .onAppear {
            loadFeaturedRecipes()
        }
    }

    private func loadFeaturedRecipes() {
        // For now, we'll create some sample recipes
        // In a real app, you would fetch these from your data store
        featuredRecipes = [
            Recipe(
                name: "Chicken Adobo",
                briefDescription: "A classic Filipino dish with chicken marinated in soy sauce, vinegar, and garlic",
                imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Chicken+Adobo"
            ),
            Recipe(
                name: "Beef Steak",
                briefDescription: "Juicy steak seared to perfection with herbs and spices",
                imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Beef+Steak"
            ),
            Recipe(
                name: "Vegetable Stir Fry",
                briefDescription: "A healthy mix of fresh vegetables quickly cooked in a wok",
                imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Vegetable+Stir+Fry"
            ),
            Recipe(
                name: "Pasta Carbonara",
                briefDescription: "Creamy Italian pasta dish with eggs, cheese, bacon, and black pepper",
                imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Pasta+Carbonara"
            )
        ]
    }
}

#Preview {
    ContentView()
}
