//
//  MockHealthTipAPI.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/11/25.
//

import Foundation

class MockHealthTipAPI {
    static let shared = MockHealthTipAPI()

    func fetchHealthTips(completion: @escaping ([HealthTip]) -> Void) {
        let mockTips = [
            HealthTip(id: UUID(), title: "Stay Hydrated", description: "Drink at least 8 glasses of water a day."),
            HealthTip(id: UUID(), title: "Take Breaks", description: "Take a 5-minute break every hour to stretch and move around."),
            HealthTip(id: UUID(), title: "Eat Healthy", description: "Include fruits and vegetables in your diet.")
        ]

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(mockTips)
        }
    }
}
