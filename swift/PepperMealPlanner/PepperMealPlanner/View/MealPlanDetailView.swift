//
//  MealPlanDetailView.swift
//  PepperMealPlanner
//
//  Created on 6/2/25.
//

import SwiftUI
import Kingfisher

struct MealPlanDetailView: View {
    var mealPlan: MealPlan

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header image
                KFImage(URL(string: mealPlan.imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(alignment: .leading, spacing: 16) {
                    // Title and description
                    Text(mealPlan.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(mealPlan.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Display each meal
                    Text("Meals in this plan")
                        .font(.headline)
                        .padding(.top, 8)

                    VStack(spacing: 12) {
                        ForEach(Array(mealPlan.recipes.keys), id: \.self) { mealType in
                            if let recipe = mealPlan.recipes[mealType] {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(mealType.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .padding(.bottom, 4)

                                    NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                                        HStack(alignment: .center, spacing: 12) {
                                            KFImage(URL(string: recipe.imageUrl ?? ""))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 70, height: 70)
                                                .cornerRadius(8)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(recipe.name)
                                                    .font(.callout)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)

                                                Text(recipe.briefDescription ?? "")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        .padding(10)
                                        .background(Color(.systemGray6).opacity(0.5))
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitle("", displayMode: .inline)
    }
}

#Preview {
    NavigationView {
        let breakfastRecipe = Recipe(
            name: "Avocado Toast with Eggs",
            briefDescription: "Healthy and delicious avocado toast topped with poached eggs",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Avocado+Toast"
        )

        let lunchRecipe = Recipe(
            name: "Chicken Caesar Salad",
            briefDescription: "Fresh romaine lettuce with grilled chicken, croutons, and Caesar dressing",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Caesar+Salad"
        )

        let dinnerRecipe = Recipe(
            name: "Grilled Salmon",
            briefDescription: "Grilled salmon with lemon butter sauce and steamed vegetables",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Grilled+Salmon"
        )

        let sampleMealPlan = MealPlan(
            name: "Healthy Start Plan",
            description: "A balanced meal plan to kickstart your healthy eating habits",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Healthy+Start+Plan",
            recipes: [
                .breakfast: breakfastRecipe,
                .lunch: lunchRecipe,
                .dinner: dinnerRecipe
            ]
        )

        return MealPlanDetailView(mealPlan: sampleMealPlan)
    }
}
