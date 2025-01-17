//
//  OnboardingView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import SwiftUI

struct OnboardingView: View {
  @Binding var showOnboarding: Bool
  @State private var selectedTab: Int = 0

  var body: some View {
    TabView(selection: $selectedTab) {
      OnboardingPageView(
        imageName: "figure.mixed.cardio",
        title: "Welcome",
        description: "Welcome to MyApp! Get started by exploring our amazing features.",
        showDoneButton: false,
        nextAction: goNext
      )
      .tag(0)

      OnboardingPageView(
        imageName: "figure.archery",
        title: "Discover",
        description: "Discover new content and stay up-to-date with the latest news and updates.",
        showDoneButton: false,
        nextAction: goNext
      )
      .tag(1)

      OnboardingPageView(
        imageName: "figure.yoga",
        title: "Connect",
        description: "Connect with friends and share your experiences with the community.",
        showDoneButton: true,
        nextAction: {
          showOnboarding = false
        }
      )
      .tag(2)
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .indexViewStyle(.page(backgroundDisplayMode: .always))
  }

  func goNext() {
    withAnimation {
      selectedTab += 1
    }
  }
}

#Preview {
  OnboardingView(showOnboarding: .constant(true))
}
