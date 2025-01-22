import SwiftUI

struct SettingsView: View {
  @Binding var apiKey: String
  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("API Configuration")) {
          SecureField("API Key", text: $apiKey)
        }
      }
      .padding()
      .navigationTitle("Settings")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  let apiKey = Binding.constant("api-key")
  SettingsView(apiKey: apiKey)
}
