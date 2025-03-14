//
//  StandupRecord.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/11/25.
//

import Foundation

struct StandUpRecord: Codable {
    let date: Date
    let standUpCount: Int
    let standUpTarget: Int
    let completed: Bool
}
