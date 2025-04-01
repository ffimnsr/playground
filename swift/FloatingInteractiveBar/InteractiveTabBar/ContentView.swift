//
//  ContentView.swift
//  InteractiveTabBar
//
//  Created by Edward Fitz Abucay on 3/27/25.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: TabItem = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            if #available(iOS 18, *) {
                TabView(selection: $activeTab) {
                    ForEach(TabItem.allCases, id: \.self) { tab in
                        Tab.init(value: tab) {
                            Text(tab.rawValue)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                }
            } else {
                TabView(selection: $activeTab) {
                    ForEach(TabItem.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                            .tag(tab)
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                }
            }

            InteractiveTabBar(activeTab: $activeTab)
        }
    }
}

struct InteractiveTabBar: View {
    @Binding var activeTab: TabItem
    /// View properites
    @Namespace private var animation

    /// Storing the locations of the Tab buttons so they can be used to identify currently dragged
    @State private var tabButtonLocations: [CGRect] = Array(repeating: .zero, count: TabItem.allCases.count)

    /// By using this, we can animate the changes in the tab bar without animating the actual tab view.
    @State private var activeDraggingTab: TabItem?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabButton(tab)
            }
        }
        .frame(height: 40)
        .padding(5)
        .background{
            Capsule()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
        }
        .coordinateSpace(.named("TABBAR"))
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? activeTab) == tab

        VStack(spacing: 6) {
            Image(systemName: tab.symbolImage)
                .symbolVariant(.fill)
                .foregroundStyle(isActive ? .white : .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if isActive {
                Capsule()
                    .fill(.blue.gradient)
                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
            }
        }
        .contentShape(.rect)
        .onGeometryChange(for: CGRect.self, of: {
            $0.frame(in: .named("TABBAR"))
        }, action: { oldValue, newValue in
            tabButtonLocations[tab.index] = newValue
        })
        .onTapGesture {
            withAnimation(.snappy) {
                activeTab = tab
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .named("TABBAR"))
                .onChanged { value in
                    let location = value.location
                    /// Checking if the location falls within any stored locations
                    if let index = tabButtonLocations.firstIndex(where: { $0.contains(location) }) {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            activeDraggingTab = TabItem.allCases[index]
                        }
                    }

                }.onEnded { _ in
                    /// Push changes to the actual tab view
                    if let activeDraggingTab {
                        activeTab = activeDraggingTab
                    }

                    activeDraggingTab = nil
                },
            isEnabled: activeTab == tab
        )
    }
}

enum TabItem: String, CaseIterable {
    case home = "Home"
    case search = "Search"
    case notifications = "Notifications"
    case settings = "Settings"

    var symbolImage: String {
        switch self {
            case .home: "house"
            case .search: "magnifyingglass"
            case .notifications: "bell"
            case .settings: "gearshape"
        }
    }

    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

#Preview {
    ContentView()
}
