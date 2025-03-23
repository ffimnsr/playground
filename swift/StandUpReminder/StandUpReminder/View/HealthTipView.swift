//
//  HealthTipView.swift
//  StandUpReminder
//
//  Created by pastel on 3/15/25.
//

import SwiftUI

struct HealthTipView: View {
    @State private var healthTips: [HealthTip] = []

    // MARK: HealthTipView Body
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
                .font(.title)

            VStack(alignment: .leading, spacing: 5) {
                Text("Health Tip")
                    .font(.headline)

                if healthTips.isEmpty {
                    Text(
                        "Standing for just 3 minutes every hour can reduce the negative health effects of prolonged sitting."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else {
                    Text(healthTips.first?.description ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button("Learn more") {
                    // Do something here
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }
            .onAppear {
                MockHealthTipAPI.shared.fetchHealthTips { tips in
                    healthTips = tips
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}


