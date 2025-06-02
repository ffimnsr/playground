//
//  MealPlanSuggestionsView.swift
//  PepperMealPlanner
//
//  Created on 6/2/25.
//

import SwiftUI

struct MealPlanSuggestionsView: View {
    @State private var mealPlans: [MealPlan] = []
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Meal Plan Suggestions")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(mealPlans) { mealPlan in
                        NavigationLink(destination: MealPlanDetailView(mealPlan: mealPlan)) {
                            MealPlanItemView(mealPlan: mealPlan)
                                .frame(width: UIScreen.main.bounds.width - 40)
                        }
                        .buttonStyle(PlainButtonStyle())
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
            loadMealPlanSuggestions()
        }
    }
    
    private func loadMealPlanSuggestions() {
        // Create some sample meal plans
        var samplePlans: [MealPlan] = []
        
        // Sample recipes for meal plans
        let breakfastRecipe1 = Recipe(
            name: "Avocado Toast with Eggs",
            briefDescription: "Healthy and delicious avocado toast topped with poached eggs",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Avocado+Toast"
        )
        
        let lunchRecipe1 = Recipe(
            name: "Chicken Caesar Salad",
            briefDescription: "Fresh romaine lettuce with grilled chicken, croutons, and Caesar dressing",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Caesar+Salad"
        )
        
        let dinnerRecipe1 = Recipe(
            name: "Grilled Salmon",
            briefDescription: "Grilled salmon with lemon butter sauce and steamed vegetables",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Grilled+Salmon"
        )
        
        let breakfastRecipe2 = Recipe(
            name: "Greek Yogurt Parfait",
            briefDescription: "Greek yogurt with fresh berries, honey, and granola",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Yogurt+Parfait"
        )
        
        let lunchRecipe2 = Recipe(
            name: "Quinoa Bowl",
            briefDescription: "Nutritious quinoa bowl with roasted vegetables and tahini dressing",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Quinoa+Bowl"
        )
        
        let dinnerRecipe2 = Recipe(
            name: "Vegetable Stir Fry",
            briefDescription: "Quick and easy vegetable stir fry with tofu and brown rice",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Vegetable+Stir+Fry"
        )
        
        // Create meal plans
        let healthyPlan = MealPlan(
            name: "Healthy Start Plan",
            description: "A balanced meal plan to kickstart your healthy eating habits",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Healthy+Start+Plan",
            recipes: [
                .breakfast: breakfastRecipe1,
                .lunch: lunchRecipe1,
                .dinner: dinnerRecipe1
            ]
        )
        
        let vegetarianPlan = MealPlan(
            name: "Vegetarian Delight",
            description: "Plant-based meals that are both delicious and nutritious",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Vegetarian+Plan",
            recipes: [
                .breakfast: breakfastRecipe2,
                .lunch: lunchRecipe2,
                .dinner: dinnerRecipe2
            ]
        )
        
        let quickMealsPlan = MealPlan(
            name: "Quick & Easy Meals",
            description: "Simple recipes that take less than 30 minutes to prepare",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Quick+Meals",
            recipes: [
                .breakfast: breakfastRecipe2,
                .lunch: lunchRecipe1,
                .dinner: dinnerRecipe2
            ]
        )
        
        let proteinPackedPlan = MealPlan(
            name: "Protein-Packed Plan",
            description: "High-protein meals to support your active lifestyle",
            imageUrl: "https://placehold.co/1280x566.png?font=raleway&text=Protein+Plan",
            recipes: [
                .breakfast: breakfastRecipe1,
                .lunch: lunchRecipe1,
                .dinner: dinnerRecipe1
            ]
        )
        
        samplePlans = [healthyPlan, vegetarianPlan, quickMealsPlan, proteinPackedPlan]
        mealPlans = samplePlans
    }
}

#Preview {
    ContentView()
}
