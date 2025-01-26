import Foundation

struct AnthropicApi {
  let base: String
  let apiPath: ApiPath
  
  enum ApiPath {
    case messages
    case textCompletions
    case countTokens
  }
}

extension AnthropicApi: Endpoint {
  var path: String {
    switch apiPath {
    case .messages: return "/v1/messages"
    case .textCompletions: return "/v1/complete"
    case .countTokens: return "/v1/messages/count_tokens"
    }
  }
}
