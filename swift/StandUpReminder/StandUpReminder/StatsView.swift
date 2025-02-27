//
//  StatsView.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 2/27/25.
//

import SwiftUI

struct StatsView: View {
    @StateObject private var statsManager = StatsManager.shared

    var body: some View {
        VStack {
            Text("Stand Up Stats")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            if statsManager.events.isEmpty {
                EmptyBarChart()
                    .frame(height: 300)
                    .padding()
            } else {
                BarChart(events: statsManager.events)
                    .frame(height: 300)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Stats", displayMode: .inline)
    }
}

#Preview {
    StatsView()
}
