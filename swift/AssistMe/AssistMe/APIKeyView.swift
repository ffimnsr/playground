import SwiftUI

struct APIKeyView: View {
  @Binding var apiKey: String

  var body: some View {
    VStack(spacing: 20) {
      Text("Welcome to AssistMe")
        .font(.title)

      Text("Please enter your Anthropic API key to continue")
        .multilineTextAlignment(.center)

      SecureField("API Key", text: $apiKey)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()

      Button("Save") {
        // Initialize chat view model with new API key
        if !apiKey.isEmpty {
          UserDefaults.standard.set(apiKey, forKey: "apiKey")
        }
      }
      .disabled(apiKey.isEmpty)
    }
    .padding()
    .frame(maxWidth: 400)
  }
}
