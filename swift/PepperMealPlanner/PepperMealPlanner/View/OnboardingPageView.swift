//
//  OnboardingPageView.swift
//  PepperMealPlanner
//
//  Created by pastel on 1/18/25.
//

import SwiftUI

struct OnboardingPageView: View {
  let imageName: String
  let title: String
  let description: String

  let showDoneButton: Bool

  var nextAction: () -> Void

  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: imageName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 250)
        .foregroundColor(.mint)

      Text(title)
        .font(.title)
        .fontWeight(.bold)

      Text(description)
        .font(.body)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
        .foregroundColor(.gray)

      if showDoneButton {
        Button("Lets get started") {
          nextAction()
        }
        .buttonStyle(.borderedProminent)
        .padding(.top)
      } else {
        Button("Next") {
          nextAction()
        }
        .buttonStyle(.bordered)
        .padding()
      }
    }
    .padding()
  }
}
