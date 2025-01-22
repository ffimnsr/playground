import Foundation

class AnthropicService {
  private let apiKey: String
  private let baseURL = "https://api.anthropic.com/v1/messages"

  init(apiKey: String = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? "") {
    self.apiKey = apiKey
  }

  func sendMessage(_ content: String) async throws -> String {
    var request = URLRequest(url: URL(string: baseURL)!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("anthropic-version: 2023-06-01", forHTTPHeaderField: "anthropic-version")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")

    let body =
      [
        "messages": [["role": "user", "content": content]],
        "model": "claude-3-sonnet-20240229",
        "max_tokens": 1024,
      ] as [String: Any]

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(AnthropicResponse.self, from: data)

    return response.content
  }
}

struct AnthropicResponse: Codable {
  let content: String
}
