//
//  MealPlanItemView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 6/2/25.
//

import SwiftUI
import Kingfisher

struct MealPlanItemView: View {
    var mealPlan: MealPlan
    let screenBounds = UIScreen.main.bounds

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Meal plan image
            KFImage(URL(string: mealPlan.imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: screenBounds.width - 40, height: 180)
                .cornerRadius(10)
                .clipped()

            // Meal plan name and description
            Text(mealPlan.name)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)

            Text(mealPlan.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)

            // Meal types included in plan
            HStack(spacing: 8) {
                ForEach(Array(mealPlan.recipes.keys), id: \.self) { mealType in
                    Text(mealType.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
