//
//  ContentView.swift
//  ChipSelection
//
//  Created by Edward Fitz Abucay on 3/28/25.
//

import SwiftUI

let tags: [String] = ["iOS 14", "SwiftUI", "Swift", "Xcode", "macOS", "watchOS", "tvOS", "iPadOS", "iOS 15", "iOS 13", "iOS 12", "iOS 11", "iOS 10", "iOS 9", "iOS 8", "iOS 7", "iOS 6", "iOS 5", "iOS 4", "iOS 3", "iOS 2", "iOS 1", "iOS 0"]

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ChipsView(tags: tags) { tag, isSelected in
                    ChipView(tag, isSelected: isSelected)
                } didChangeSelection: { selection in
                    print(selection)
                }
                .padding(10)
                .background(.gray.opacity(0.1), in: .rect(cornerRadius: 20))
            }
            .padding(15)
            .navigationTitle("Chips Selection")
        }
    }

    @ViewBuilder
    func ChipView(_ tag: String, isSelected: Bool) -> some View {
        HStack(spacing: 10) {
            Text(tag)
                .font(.callout)
                .foregroundStyle(isSelected ? .white : .primary)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.white)

            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            ZStack {
                Capsule()
                    .fill(.background)
                    .opacity(!isSelected ? 1 : 0)

                Capsule()
                    .fill(.green.gradient)
                    .opacity(isSelected ? 1 : 0)
            }
        }
    }
}

#Preview {
    ContentView()
}
