import SwiftUI

struct HabitListView: View {
    @EnvironmentObject private var store: HabitStore

    let habits: [Habit]
    @Binding var selectedFilter: Habit.Status?
    @Binding var searchText: String
    @Binding var selection: Habit?
    var onCreate: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HabitFilterBar(selectedStatus: $selectedFilter)
                .padding(.horizontal)
                .padding(.top)
            List(selection: $selection) {
                if habits.isEmpty {
                    EmptyStateView(title: "No Habits",
                                   systemImage: "tray",
                                   message: "Start capturing wins with the plus button.")
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                }
                ForEach(habits) { habit in
                    NavigationLink(value: habit) {
                        HabitRowView(habit: habit)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            store.delete(ids: [habit.id])
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete { offsets in
                    let ids = offsets.map { habits[$0].id }
                    store.delete(ids: Array(ids))
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search habits")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onCreate) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Create habit")
            }
        }
    }
}

#Preview("Empty") {
    NavigationSplitView {
        HabitListView(habits: [],
                      selectedFilter: .constant(nil),
                      searchText: .constant(""),
                      selection: .constant(nil),
                      onCreate: {})
            .environmentObject(HabitStore(sampleData: []))
    } detail: {
        Text("Detail")
    }
}

#Preview("Content") {
    NavigationSplitView {
        HabitListView(habits: Habit.sampleData,
                      selectedFilter: .constant(nil),
                      searchText: .constant(""),
                      selection: .constant(nil),
                      onCreate: {})
            .environmentObject(HabitStore(sampleData: Habit.sampleData))
    } detail: {
        Text("Detail")
    }
}
