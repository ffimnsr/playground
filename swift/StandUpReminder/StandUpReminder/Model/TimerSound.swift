//
//  TimerSound.swift
//  StandUpReminder
//
//  Created by Edward Fitz Abucay on 3/11/25.
//

import AudioToolbox

enum TimerSound: String, CaseIterable, Identifiable {
    case alert = "Alert"
    case bell = "Bell"
    case chime = "Chime"
    case glass = "Glass"
    case horn = "Horn"
    case note = "Note"

    var id: String { rawValue }

    var soundID: SystemSoundID {
        switch self {
            case .alert: return 1005
            case .bell: return 1006
            case .chime: return 1007
            case .glass: return 1020
            case .horn: return 1023
            case .note: return 1027
        }
    }
}
