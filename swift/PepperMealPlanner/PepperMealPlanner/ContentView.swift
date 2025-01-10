//
//  ContentView.swift
//  PepperMealPlanner
//
//  Created by Edward Fitz Abucay on 1/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Hello, world!")
                }
            }
            .navigationTitle("Pepper Meal Planner")
        }
    }
}

#Preview {
    ContentView()
}
