//
//  ExpenseItem.swift
//  iExpense
//
//  Created by Edward Fitz Abucay on 1/10/25.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}
