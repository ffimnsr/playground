//
//  ContentView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/10/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(Tab.home)
                    .tabItem {
                        Image(systemName: Tab.home.rawValue)
                        Text("Home")
                    }
                RecipeListView()
                    .tag(Tab.recipes)
                    .tabItem {
                        Image(systemName: Tab.recipes.rawValue)
                        Text("Recipes")
                    }
                PlannerView()
                    .tag(Tab.planner)
                    .tabItem {
                        Image(systemName: Tab.planner.rawValue)
                        Text("Planner")
                    }
                Text("Stats View")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(Tab.stats)
                    .tabItem {
                        Image(systemName: Tab.stats.rawValue)
                        Text("Stats")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
