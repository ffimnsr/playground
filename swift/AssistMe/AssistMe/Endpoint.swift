import Foundation

enum HttpMethod: String {
  case post = "POST"
  case get = "GET"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

protocol Endpoint {
  var base: String { get }
  var path: String { get }
}

extension Endpoint {
  func urlComponents(queryItems: [URLQueryItem] = []) -> URLComponents {
    var components = URLComponents(string: base)!
    components.path = components.path.appending(path)
    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }
    
    return components
  }
  
  func request(
    apiKey: String,
    apiVersion: String,
    method: HttpMethod,
    params: Encodable? = nil,
    queryItems: [URLQueryItem] = []
  ) throws -> URLRequest {
    var request = URLRequest(url: urlComponents(queryItems: queryItems).url!)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(apiKey)", forHTTPHeaderField: "x-api-key")
    request.addValue("\(apiVersion)", forHTTPHeaderField: "anthropic-version")
    request.httpMethod = method.rawValue
    if let params {
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase
      request.httpBody = try encoder.encode(params)
    }
    return request
  }
}
