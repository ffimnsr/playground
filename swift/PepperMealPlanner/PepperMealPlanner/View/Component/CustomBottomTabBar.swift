//
//  CustomBottomTabBar.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/14/25.
//

import SwiftUI

private let buttonSize: CGFloat = 55

struct CustomBottomTabBar: View {
    @Binding var currentTab: Tab

    var body: some View {
        HStack {
            TabBarButton(imageName: Tab.home.rawValue)
                .frame(width: buttonSize, height: buttonSize)
                .onTapGesture {
                    currentTab = .home
                }

            Spacer()

            TabBarButton(imageName: Tab.recipes.rawValue)
                .frame(width: buttonSize, height: buttonSize)
                .onTapGesture {
                    currentTab = .recipes
                }

            Spacer()

            TabBarButton(imageName: Tab.profile.rawValue)
                .frame(width: buttonSize, height: buttonSize)
                .onTapGesture {
                    currentTab = .profile
                }
        }
        .frame(width: (buttonSize * CGFloat(Tab.allCases.count)) + 60)
        .tint(.black)
        .padding(.vertical, 2.5)
        .background(.white)
        .clipShape(Capsule(style: .continuous))
        .overlay {
            SelectedTabCircle(currentTab: $currentTab)
        }
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 10)
        .animation(
            .interactiveSpring(response: 0.5, dampingFraction: 0.65, blendDuration: 0.65),
            value: currentTab)
    }

    struct TabBarButton: View {
        let imageName: String
        var body: some View {
            Image(systemName: imageName)
                .renderingMode(.template)
                .tint(.black)
                .fontWeight(.bold)
        }
    }

    struct SelectedTabCircle: View {
        @Binding var currentTab: Tab

        private var horizontalOffset: CGFloat {
            switch currentTab {
            case .home: return -84
            case .recipes: return 0
            case .profile: return 84
            }
        }

        var body: some View {
            ZStack {
                Circle()
                    .fill(.blue)
                    .frame(width: buttonSize, height: buttonSize)

                TabBarButton(imageName: "\(currentTab.rawValue).fill")
                    .foregroundStyle(.white)
            }
            .offset(x: horizontalOffset)
        }
    }
}

#Preview {
    @Previewable @State var currentTab: Tab = .home
    CustomBottomTabBar(currentTab: $currentTab)
}
