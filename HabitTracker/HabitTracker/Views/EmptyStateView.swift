import SwiftUI

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title3)
                .bold()
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .padding(32)
    }
}

#Preview {
    EmptyStateView(title: "No Habits",
                   systemImage: "tray",
                   message: "Start capturing wins with the plus button.")
}
