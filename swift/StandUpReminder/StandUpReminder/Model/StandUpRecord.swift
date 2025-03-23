//
//  StandUpRecord.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/11/25.
//

import SwiftUI
import SwiftData
import CryptoKit

@Model
class StandUpRecord: Codable {
    var timestamp: Date
    var count: Int
    var target: Int
    var completed: Bool
    
    init(target: Int) {
        let calender = Calendar.current
        let components = calender.dateComponents([.year, .month, .day], from: .now)
        
        self.timestamp = calender.date(from: components) ?? .now
        self.count = 0
        self.target = target
        self.completed = false
    }

    init(timestamp: Date, count: Int, target: Int, completed: Bool) {
        self.timestamp = timestamp
        self.count = count
        self.target = target
        self.completed = completed
    }

    enum CodingKeys: CodingKey {
        case timestamp, count, target, completed
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        count = try container.decode(Int.self, forKey: .count)
        target = try container.decode(Int.self, forKey: .target)
        completed = try container.decode(Bool.self, forKey: .completed)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(count, forKey: .count)
        try container.encode(target, forKey: .target)
        try container.encode(completed, forKey: .completed)
    }
}

struct StandUpRecordTransferable: Transferable {
    var records: [StandUpRecord]
    var key: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) {
            let data = try JSONEncoder().encode($0.records)
            guard let encryptedData = try? AES.GCM.seal(data, using: .key($0.key)).combined else {
                throw EncryptionError.encryptionFailed
            }

            return encryptedData
        }
    }

    enum EncryptionError: Error {
        case encryptionFailed
    }
}
