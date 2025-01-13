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
      HomeView().navigationBarHidden(true)
    }
  }
}

#Preview {
  ContentView()
}
