//
//  VerificationField.swift
//  AnimatedOTPCodeTextField
//
//  Created by Edward Fitz Abucay on 3/27/25.
//

import SwiftUI

/// Properties
enum CodeType: Int, CaseIterable {
    case four = 4
    case six = 6

    var stringValue: String {
        "\(rawValue) Digit"
    }
}

enum TypingState {
    case typing
    case valid
    case invalid
}

enum TextFieldStyle: String, CaseIterable {
    case roundedBorder = "Rounded Border"
    case underline = "Underline"
}

struct VerificationField: View {
    var type: CodeType
    var style: TextFieldStyle = .roundedBorder
    @Binding var value: String
    /// View properties
    @State private var state: TypingState = .typing
    @State private var invalidTrigger: Bool = false
    @FocusState private var isActive: Bool
    var onChange: (String) async -> TypingState
    var body: some View {
        HStack(spacing: style == .roundedBorder ? 6 : 10) {
            ForEach(0..<type.rawValue, id: \.self) { index in
                CharacterView(index)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: value)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .compositingGroup()
        /// Invalid phase animator
        .phaseAnimator(
            [0, 10, -10, 10, -5, 5, 0],
            trigger: invalidTrigger,
            content: { content, offset in
                content
                    .offset(x: offset)
            },
            animation: { _ in
                    .linear(duration: 0.06)
            }
        )
        .background {
            TextField("", text: $value)
                .focused($isActive)
                .keyboardType(.numberPad)
                /// Adds automatic OTP code filling
                .textContentType(.oneTimeCode)
                .mask(alignment: .trailing) {
                    Rectangle()
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                }
                .allowsHitTesting(false)
        }
        .contentShape(.rect)
        .onTapGesture {
            isActive = true
        }
        .onChange(of: value) { oldValue, newValue in
            value = String(newValue.prefix(type.rawValue))
            Task { @MainActor in
                /// For validation check
                state = await onChange(value)
                if state == .invalid {
                    invalidTrigger.toggle()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isActive = false
                }
                .tint(Color.primary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    @ViewBuilder
    func CharacterView(_ index: Int) -> some View {
        Group {
            if style == .roundedBorder {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor(index), lineWidth: 1.2)
            } else {
                Rectangle()
                    .fill(borderColor(index))
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(width: style == .roundedBorder ? 50 : 40, height: 50)
        .overlay {
            let stringValue = string(index)

            if stringValue != "" {
                Text(stringValue)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .transition(.blurReplace)
            }
        }
    }

    func string(_ index: Int) -> String {
        if value.count > index {
            let startIndex = value.startIndex
            let stringIndex = value.index(startIndex, offsetBy: index)

            return String(value[stringIndex])
        }

        return ""
    }

    func borderColor(_ index: Int) -> Color {
        switch state {
            case .typing: value.count == index && isActive ? Color.primary : .gray
            case .valid: .green
            case .invalid: .red
        }
    }
}

#Preview {
    ContentView()
}
