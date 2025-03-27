//
//  View+CustomAlert.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/24/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func alert<Content: View, Background: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder background: @escaping () -> Background
    ) -> some View {
        self
            .modifier(
                CustomAlertModifier(
                    isPresented: isPresented,
                    alertContent: content,
                    background: background
                )
            )
    }
}

fileprivate struct CustomAlertModifier<AlertContent: View, Background: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder var alertContent: AlertContent
    @ViewBuilder var background: Background

    @State private var isShowFullScreenCover: Bool = false
    @State private var isAnimatedValue: Bool = false

    // This is to prevent user interaction while the alert is animating
    @State private var isAllowInteraction: Bool = false

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    if isAnimatedValue {
                        alertContent
                            .allowsHitTesting(isAllowInteraction)
                    }
                }
                .presentationBackground {
                    background
                        .allowsHitTesting(isAllowInteraction)
                        .opacity(isAnimatedValue ? 1 : 0)
                }
                .task {
                    try? await Task.sleep(for: .seconds(0.05))
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAnimatedValue = true
                    }
                    isAnimatedValue = true

                    try? await Task.sleep(for: .seconds(0.3))
                    isAllowInteraction = true
                }
            }
            .onChange(of: isPresented) {
 oldValue,
 newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true

                if newValue {
                    withTransaction(transaction) {
                        isShowFullScreenCover = true
                    }
                } else {
                    isAllowInteraction = false
                    withAnimation(
                        .easeInOut(duration: 0.3),
                        completionCriteria: .removed
                    ) {
                        isAnimatedValue = false
                    } completion: {
                        withTransaction(transaction) {
                            isShowFullScreenCover = false
                        }
                    }
                }
            }
    }
}

struct CustomDialog: View {
    var title: String
    var content: String?
    var image: Config
    var button1: Config
    var button2: Config?


    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: image.content)
                .font(.title)
                .foregroundStyle(image.foreground)
                .frame(width: 65, height: 65)
                .background(image.tint.gradient, in: .circle)
                .background {
                    Circle()
                        .stroke(.background, lineWidth: 8)
                }

            Text(title)
                .font(.title.bold())

            if let content {
                Text(content)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(.gray)
            }

            ButtonView(button1)

            if let button2 {
                ButtonView(button2)
                    .padding(.top, -5)
            }
        }
        .padding([.horizontal, .bottom], 15)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .padding(.top, 30)
        }
        .frame(maxWidth: 310)
        .compositingGroup()
    }

    @ViewBuilder
    private func ButtonView(_ config: Config) -> some View {
        Button {
            config.action("")
        } label: {
            Text(config.content)
                .fontWeight(.bold)
                .foregroundStyle(config.foreground)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(config.tint.gradient, in: .rect(cornerRadius: 10))
        }
    }

    struct Config {
        var content: String
        var tint: Color
        var foreground: Color
        var action: (String) -> () = { _ in }
    }
}


#Preview {
    @Previewable @State var isShowAlert = false
    NavigationStack {
        List {
            Button("Show Alert") {
                isShowAlert.toggle()
            }
            .alert(isPresented: $isShowAlert) {
                CustomDialog(
                    title: "Folder Name",
                    content: "Hello, World!",
                    image: .init(
                        content: "folder.fill.badge.plus",
                        tint: .blue,
                        foreground: .white
                    ),
                    button1: .init(content: "Save", tint: .blue, foreground: .white, action: { _ in
                        print("Save")
                    }),
                    button2: .init(
                        content: "Cancel",
                        tint: .red,
                        foreground: .white,
                        action: { _ in
                            isShowAlert = false
                        }
                    )
                )
                .transition(.blurReplace.combined(with: .push(from: .bottom)))

            } background: {
                Rectangle()
                    .fill(.primary.opacity(0.35))
            }
        }
        .navigationTitle("Custom Alert")
    }
    .overlay {

    }
}
