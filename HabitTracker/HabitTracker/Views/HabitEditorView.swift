import SwiftUI

enum HabitEditorResult {
    case success(Habit)
    case delete
    case cancel
}

struct HabitEditorView: View {
    enum Mode {
        case new
        case edit(Habit)

        var title: String {
            switch self {
            case .new: return "New Habit"
            case .edit: return "Edit Habit"
            }
        }
    }

    let mode: Mode
    var completion: (HabitEditorResult) -> Void

    @State private var workingCopy: Habit
    @State private var hasDueDate: Bool

    init(mode: Mode, completion: @escaping (HabitEditorResult) -> Void) {
        self.mode = mode
        self.completion = completion
        switch mode {
        case .new:
            let initial = Habit(title: "", summary: "", status: .planned)
            _workingCopy = State(initialValue: initial)
            _hasDueDate = State(initialValue: false)
        case .edit(let habit):
            _workingCopy = State(initialValue: habit)
            _hasDueDate = State(initialValue: habit.dueAt != nil)
        }
    }

    var body: some View {
        Form {
            Section("Overview") {
                TextField("Title", text: $workingCopy.title)
                TextField("Summary", text: $workingCopy.summary, axis: .vertical)
                    .lineLimit(2...4)
                Picker("Category", selection: $workingCopy.category) {
                    ForEach(Habit.Category.allCases) { category in
                        Text(category.title).tag(category)
                    }
                }
            }

            Section("Status") {
                Picker("Status", selection: $workingCopy.status) {
                    ForEach(Habit.Status.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }

                Toggle("Set Due Date", isOn: $hasDueDate.animation())
                if hasDueDate {
                    DatePicker("Due Date",
                               selection: Binding(get: {
                                   workingCopy.dueAt ?? .now
                               }, set: { newValue in
                                   workingCopy.dueAt = newValue
                               }),
                               displayedComponents: [.date])
                }

                Toggle("Mark as Completed", isOn: Binding(get: {
                    workingCopy.completedAt != nil
                }, set: { newValue in
                    workingCopy.completedAt = newValue ? (workingCopy.completedAt ?? Date()) : nil
                }))
                if let completed = workingCopy.completedAt {
                    DatePicker("Completed On",
                               selection: Binding(get: { completed }, set: { workingCopy.completedAt = $0 }),
                               displayedComponents: [.date])
                }
            }

            Section("Notes") {
                TextEditor(text: $workingCopy.notes)
                    .frame(minHeight: 120)
            }
        }
        .onChange(of: hasDueDate) { newValue in
            if newValue {
                workingCopy.dueAt = workingCopy.dueAt ?? .now
            } else {
                workingCopy.dueAt = nil
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { completion(.cancel) }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if workingCopy.completedAt == nil && workingCopy.status == .completed {
                        workingCopy.completedAt = Date()
                    }
                    completion(.success(workingCopy))
                }
                .disabled(workingCopy.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            if case .edit = mode {
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        completion(.delete)
                    } label: {
                        Label("Delete Habit", systemImage: "trash")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

#Preview("New") {
    NavigationStack {
        HabitEditorView(mode: .new) { _ in }
    }
}

#Preview("Edit") {
    NavigationStack {
        HabitEditorView(mode: .edit(Habit.sampleData[0])) { _ in }
    }
}
