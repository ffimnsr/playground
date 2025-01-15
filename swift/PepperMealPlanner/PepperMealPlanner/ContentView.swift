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
          .toolbar(.hidden, for: .tabBar)
          .tag(Tab.home)
        RecipeListView()
          .toolbar(.hidden, for: .tabBar)
          .tag(Tab.recipes)
        Text("PROFILE")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .toolbar(.hidden, for: .tabBar)
          .tag(Tab.profile)
      }
      
      CustomBottomTabBarView(currentTab: $selectedTab)
        .padding(.bottom)
    }
  }
}

#Preview {
  ContentView()
}
