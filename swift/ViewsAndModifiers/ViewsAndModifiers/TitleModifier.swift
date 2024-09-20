//
//  TitleModifier.swift
//  ViewsAndModifiers
//
//  Created by Edward Fitz Abucay on 9/20/24.
//

import SwiftUI

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.blue)
            .padding()
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(Title())
    }
}
