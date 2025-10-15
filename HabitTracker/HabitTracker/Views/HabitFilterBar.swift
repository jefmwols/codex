import SwiftUI

struct HabitFilterBar: View {
    @Binding var selectedStatus: Habit.Status?

    private let statuses: [Habit.Status?] = [nil] + Habit.Status.allCases.map { Optional($0) }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(statuses, id: \.self) { status in
                    let isSelected = selectedStatus == status
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedStatus = (isSelected ? nil : status)
                        }
                    } label: {
                        Label(statusTitle(status), systemImage: systemImage(for: status))
                            .labelStyle(.titleAndIcon)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(isSelected ? Color.accentColor.opacity(0.2) : Color(UIColor.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func statusTitle(_ status: Habit.Status?) -> String {
        switch status {
        case .none: return "All"
        case .some(let value): return value.title
        }
    }

    private func systemImage(for status: Habit.Status?) -> String {
        switch status {
        case .none: return "line.3.horizontal.decrease"
        case .some(let value): return value.systemImage
        }
    }
}

#Preview {
    HabitFilterBar(selectedStatus: .constant(nil))
        .padding()
}
