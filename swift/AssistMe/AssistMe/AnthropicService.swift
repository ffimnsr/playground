import Foundation

class AnthropicService {
  private let session: URLSession
  private let decoder: JSONDecoder
  private let apiKey: String
  private let apiVersion: String
  private let baseURL = "https://api.anthropic.com"

  init(
    apiKey: String = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? "",
    apiVersion: String = "2023-06-01"
  ) {
    self.session = URLSession(configuration: .default)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    self.decoder = decoder
    self.apiKey = apiKey
    self.apiVersion = apiVersion
    se
  }
  
  func sendMessage(_ content: String) async throws -> String {
    let request = try AnthropicApi(base: baseURL, apiPath: .messages)
      .request(apiKey: apiKey, apiVersion: apiVersion, method: .post, params: nil)

    let body =
      [
        "messages": [["role": "user", "content": content]],
        "model": "claude-3-sonnet-20240229",
        "max_tokens": 1024,
      ] as [String: Any]

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, _) = try await URLSession.shared.data(for: request)
    
    print(String(data: data, encoding: .utf8)!)
    let response = try JSONDecoder().decode(AnthropicResponse.self, from: data)

    print(response.content)
    return response.content
  }
  
  func fetch<T: Decodable>(
    type: T.Type,
    with request: URLRequest,
  ) async throws -> T {
      let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      fatalError("Invalid response unable to get a valid HTTPURLResponse")
    }
  }
}

struct AnthropicResponse: Codable {
  let content: String
}
