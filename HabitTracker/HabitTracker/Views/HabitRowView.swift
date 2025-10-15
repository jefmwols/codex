import SwiftUI

struct HabitRowView: View {
    let habit: Habit

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            statusIcon
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                if !habit.summary.isEmpty {
                    Text(habit.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                HStack(spacing: 8) {
                    Label(habit.category.title, systemImage: "tag")
                        .labelStyle(.iconOnly)
                        .foregroundColor(color(for: habit.category))
                        .accessibilityLabel("Category \(habit.category.title)")
                    Label(habit.schedule.title, systemImage: "repeat")
                        .foregroundStyle(.secondary)
                    if let dueDate = habit.dueAt {
                        Label(DateFormatter.shortDateFormatter.string(from: dueDate), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private var statusIcon: some View {
        Image(systemName: habit.status.systemImage)
            .font(.title3)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(color(for: habit.category))
            .frame(width: 32, height: 32)
            .accessibilityHidden(true)
    }

    private func color(for category: Habit.Category) -> Color {
        switch category {
        case .productivity: return .blue
        case .wellness: return .green
        case .learning: return .purple
        case .home: return .orange
        case .personal: return .pink
        }
    }
}

#Preview {
    List(Habit.sampleData) { habit in
        HabitRowView(habit: habit)
    }
}
