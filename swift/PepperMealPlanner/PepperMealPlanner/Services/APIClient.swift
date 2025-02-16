//
//  APIClient.swift
//  PepperMealPlanner
//
//  Created by pastel on 2/16/25.
//

import Foundation

class APIClient {
  static let shared = APIClient()
  
  private let baseURL = URL(string: "http://localhost:1337")!
  
  private init() {}
  
  func fetchRecipes(completion: @escaping (Result<Bool, Error>) -> Void) {
    let endpoint = baseURL.appendingPathComponent("/api/recipes")
    var request = URLRequest(url: endpoint)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
   
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        let statusError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        completion(.failure(statusError))
        return
      }
      
      completion(.success(true))
    }
    
    task.resume()
  }
}
