//
//  View+Extensions.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/19/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }

    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }

    @ViewBuilder
    func applyPaddedBackground(_ radius: CGFloat, hPadding: CGFloat = 15, vPadding: CGFloat = 15) -> some View {
        self
            .padding(.horizontal, hPadding)
            .padding(.vertical, vPadding)
            .background(.background, in: .rect(cornerRadius: radius))
    }

    @ViewBuilder
    func disabledWithOpacity(_ isDisabled: Bool) -> some View {
        self
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1)
    }

    @ViewBuilder
    func opacityShadow(_ color: Color, radius: CGFloat, opacity: CGFloat) -> some View {
        self
            .shadow(color: color.opacity(opacity), radius: radius)
    }
}
