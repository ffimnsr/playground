//
//  Home.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    FeaturedRecipesView()

                    MealPlanSuggestionsView()

                    Spacer()
                        .frame(height: 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
