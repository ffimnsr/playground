import Observation
import SwiftUI

@Observable
class ChatViewModel {
  var messages: [Message] = []
  private let anthropicService: AnthropicService

  init() {
    let apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
    self.anthropicService = AnthropicService(apiKey: apiKey)
  }

  func sendMessage(_ content: String) {
    let userMessage = Message(content: content, isUser: true, timestamp: Date())
    messages.append(userMessage)

    Task {
      do {
        let response = try await anthropicService.sendMessage(content)
        // No need for DispatchQueue.main.async since @Observable handles updates
        let assistantMessage = Message(content: response, isUser: false, timestamp: Date())
        messages.append(assistantMessage)
      } catch {
        print("Error: \(error)")
      }
    }
  }
}
