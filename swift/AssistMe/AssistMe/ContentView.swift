import SwiftUI

struct ContentView: View {
  @State private var chatViewModel = ChatViewModel()
  @State private var messageText = ""
  @State private var showingSettings = false
  @AppStorage("apiKey") private var apiKey = ""

  var body: some View {
    NavigationStack {
      VStack {
        if apiKey.isEmpty {
          APIKeyView()
        } else {
          ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
              ForEach(chatViewModel.messages) { message in
                MessageView(message: message)
              }
            }
            .padding()
          }
          
          HStack {
            TextField("Type a message...", text: $messageText)
              .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: sendMessage) {
              Text("Send")
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
          }
          .padding()
        }
      }
      .navigationTitle("Assist Me")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(action: { showingSettings.toggle() }) {
            Image(systemName: "gear")
          }
        }
      }
      .sheet(isPresented: $showingSettings) {
        SettingsView(apiKey: $apiKey)
      }
    }
  }

  private func sendMessage() {
    guard !messageText.isEmpty else { return }
    chatViewModel.sendMessage(messageText)
    messageText = ""
  }
}

#Preview {
  ContentView()
}
