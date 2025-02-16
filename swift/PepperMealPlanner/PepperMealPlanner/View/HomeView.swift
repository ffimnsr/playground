//
//  Home.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import Observation
import SwiftUI

struct HomeView: View {
  @State private var viewModel = HomeViewModel()

  var body: some View {
    NavigationStack {
      VStack {
        HStack(spacing: 15) {
          Text("Today's Menu")
            .font(.title)
            .fontWeight(.medium)
            .foregroundStyle(.primary)

          Spacer()
        }
        .padding([.horizontal, .top])

//        DateScroller()
//          .frame(maxHeight: 120)
        Divider()

        ScrollView(.vertical, showsIndicators: false) {
          VStack(spacing: 25) {
            ForEach(1...5, id: \.self) { _ in
              let recipe = Recipe(name: "Spaghetti", imageUrl: "spaghetti")
              NavigationLink(destination: {
                Text("Detail view")
              }) {
                RecipeItemView(recipe: recipe)
              }
            }
          }
          .padding(.bottom, 100)
        }
        Spacer()
      }
    }
  }
}

#Preview {
  HomeView()
}
