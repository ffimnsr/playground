//
//  CalendarView.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/19/25.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(), count: WeekdayName.allCases.count),
            spacing: 12
        ) {
            ForEach(WeekdayName.allCases, id: \.rawValue) { day in
                Text(day.rawValue.prefix(3))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            ForEach(0..<Date.startOffsetOfThisMonth, id: \.self) { _ in
                Circle()
                    .fill(.clear)
                    .frame(height: 30)
                    .hSpacing(.center)
            }

            ForEach(Date.datesInThisMonth, id: \.self) { date in
                let day = date.format("dd")
                Text(day)
                    .font(.caption)
                    .frame(height: 30)
                    .hSpacing(.center)
                    .background { Circle().fill(.fill) }
            }
        }
    }
}

#Preview {
    CalendarView()
}
