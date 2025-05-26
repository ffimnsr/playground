//
//  Home.swift
//  TaskManagementAppUI
//
//  Created by Edward Fitz Abucay on 5/21/25.
//

import SwiftUI

struct Home: View {
    @State private var currentWeek: [Date] = Date.currentWeek
    @State private var selectedDate: Date?

    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()

            GeometryReader {
                let size = $0.size
            }
        }
    }

    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.title)
                    .fontWeight(.semibold)

                Spacer(minLength: 0)

                Button {

                } label: {
                    Image(systemName: "chevron.right")
                }
            }
        }
    }
}

#Preview {
    Home()
}
