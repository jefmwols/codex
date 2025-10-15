import SwiftUI

struct HabitDetailView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.dismiss) private var dismiss

    let habitID: Habit.ID
    @State private var isEditing = false

    private var habit: Habit? {
        store.habit(id: habitID)
    }

    var body: some View {
        Group {
            if let habit {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header(for: habit)
                        Divider()
                        if !habit.summary.isEmpty {
                            Text(habit.summary)
                                .font(.title3)
                        }
                        keyDates(for: habit)
                        if !habit.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)
                                Text(habit.notes)
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle(habit.title)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                EmptyStateView(title: "Habit Not Found",
                               systemImage: "exclamationmark.triangle",
                               message: "This habit may have been deleted.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar {
            if habit != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") { isEditing = true }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            if let habit {
                NavigationStack {
                    HabitEditorView(mode: .edit(habit)) { result in
                        switch result {
                        case .success(let updated):
                            store.update(updated)
                        case .delete:
                            store.delete(ids: [habit.id])
                            dismiss()
                        case .cancel:
                            break
                        }
                        isEditing = false
                    }
                }
            }
        }
    }

    private func header(for habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(habit.category.title, systemImage: "tag")
                .font(.headline)
            Label(habit.status.title, systemImage: habit.status.systemImage)
                .labelStyle(.titleAndIcon)
            Label(habit.schedule.description, systemImage: "repeat")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func keyDates(for habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Timeline")
                .font(.headline)
            HStack {
                Label("Created", systemImage: "calendar")
                Spacer()
                Text(DateFormatter.fullDateFormatter.string(from: habit.createdAt))
            }
            if let due = habit.dueAt {
                HStack {
                    Label("Due", systemImage: "flag")
                    Spacer()
                    Text(DateFormatter.fullDateFormatter.string(from: due))
                }
            }
            if let completed = habit.completedAt {
                HStack {
                    Label("Completed", systemImage: "checkmark")
                    Spacer()
                    Text(DateFormatter.fullDateFormatter.string(from: completed))
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    NavigationStack {
        HabitDetailView(habitID: Habit.sampleData[0].id)
            .environmentObject(HabitStore(sampleData: Habit.sampleData))
    }
}
