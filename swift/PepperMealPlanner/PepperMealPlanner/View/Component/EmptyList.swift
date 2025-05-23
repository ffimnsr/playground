//
//  EmptyList.swift
//  PepperMealPlanner
//
//  Created by pastel on 1/17/25.
//

import SwiftUI

struct EmptyList: View {
    var body: some View {
        VStack {
            Image(systemName: "tray")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
            Text("Recipe list is empty")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding()
    }
}
