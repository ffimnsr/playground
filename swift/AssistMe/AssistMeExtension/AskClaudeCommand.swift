//
//  AskClaudeCommand.swift
//  AssistMe
//
//  Created by pastel on 1/22/25.
//

import Foundation
import XcodeKit

class AskClaudeCommand: NSObject, XCSourceEditorCommand {
  func perform(
    with invocation: XCSourceEditorCommandInvocation,
    completionHandler: @escaping (Error?) -> Void
  ) {
    completionHandler(nil)
  }
}
