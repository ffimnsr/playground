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
        .frame(height: 70)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        .background{
            Rectangle()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
                .ignoresSafeArea()
                .padding(.top, 20)
        }
        .coordinateSpace(.named("TABBAR"))
    }

    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? activeTab) == tab

        VStack(spacing: 6) {
            Image(systemName: tab.symbolImage)
                .symbolVariant(.fill)
                .frame(width: isActive ? 50 : 25, height: isActive ? 50 : 25)
                .background {
                    if isActive {
                        Circle()
                            .fill(.blue.gradient)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                    }
                }
                /// This gives us the elevation we needed to push the active tab
                .frame(width: 25, height: 25, alignment: .bottom)
                .foregroundStyle(isActive ? .white : .primary)

            Text(tab.rawValue)
                .font(.caption2)
                .foregroundStyle(isActive ? .blue : .gray)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
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
