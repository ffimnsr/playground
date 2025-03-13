//
//  StandupRecord.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/11/25.
//

import Foundation

struct StandupRecord: Codable {
    let date: Date
    let standupCount: Int
    let standupTarget: Int
    let completed: Bool
}
