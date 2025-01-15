//
//  DateScroller.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/13/25.
//

import SwiftUI

struct DateScroller: View {
  @State private var selectedDate: Date = .init()

  private let dates: [Date] = {
    var dates = [Date]()
    let calendar = Calendar.current
    let today = Date()
    let range = calendar.range(of: .day, in: .month, for: today)!
    let components = calendar.dateComponents([.year, .month], from: today)
    let startOfMonth = calendar.date(from: components)!
    
    for day in range {
      if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
        dates.append(date)
      }
    }
    return dates
  }()

  private let today = Calendar.current.startOfDay(for: Date())

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 16) {
          ForEach(dates, id: \.self) { date in
            Button(action: {
              selectedDate = date
            }) {
              VStack {
                Text(date, formatter: DateFormatter.dayFormatter)
                  .font(.largeTitle)
                  .fontWeight(.bold)
                
                Text(date, formatter: DateFormatter.weekdayFormatter)
                  .font(.caption)
              }
              .padding()
              .frame(width: 80, height: 100)
              .background(
                RoundedRectangle(cornerRadius: 10)
                  .fill(date == selectedDate ? Color.orange.opacity(0.2) : (date == today ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2)))
              )
            }
            .buttonStyle(PlainButtonStyle())
            .id(date)
          }
        }
      }
      .onAppear {
        selectedDate = today
        DispatchQueue.main.async {
          proxy.scrollTo(today, anchor: .center)
        }
      }
    }
    .padding()
  }
}

#Preview {
  DateScroller()
}
