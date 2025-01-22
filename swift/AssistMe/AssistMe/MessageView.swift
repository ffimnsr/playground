import SwiftUI

struct MessageView: View {
  let message: Message

  var body: some View {
    HStack {
      if message.isUser {
        Spacer()
      }

      Text(message.content)
        .padding()
        .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
        .foregroundColor(message.isUser ? .white : .primary)
        .cornerRadius(12)

      if !message.isUser {
        Spacer()
      }
    }
  }
}
