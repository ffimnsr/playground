//
//  SourceEditorExtension.swift
//  AssistMeExtension
//
//  Created by pastel on 1/22/25.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {

  /*
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
    }
    */

  var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
    return [
      [
        .classNameKey: "AssistMeExtension.AskClaudeCommand",
        .identifierKey: "com.vastorigins.AssistMeExtension.AskClaudeCommand",
        .nameKey: "Ask Claude",
      ]
    ]
  }

}
