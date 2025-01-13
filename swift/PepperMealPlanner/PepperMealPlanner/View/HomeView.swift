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
    VStack {
      HStack(spacing: 15) {
        Button(
          action: {
            print("Menu Tapped")
          },
          label: {
            Image(systemName: "line.horizontal.3")
              .font(.title)
              .foregroundStyle(.primary)
          }
        )

        Text("Today's Menu")
          .font(.title)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Spacer()
      }
      .padding([.horizontal, .top])

      DateScrollerView()
      Divider()

      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 25) {
          ForEach(1...5, id: \.self) { _ in
            RecipeItemView(recipe: Recipe(name: "Spaghetti", imageUrl: "spaghetti"))
          }
        }
      }
      Spacer()
    }
  }
}

#Preview {
  HomeView()
}
