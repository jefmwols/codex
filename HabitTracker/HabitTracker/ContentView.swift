import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: HabitStore
    @State private var searchText = ""
    @State private var selectedFilter: Habit.Status? = nil
    @State private var showingCreateSheet = false
    @State private var selection: Habit?

    private var filteredHabits: [Habit] {
        store.filteredHabits(searchText: searchText, status: selectedFilter)
    }

    var body: some View {
        NavigationSplitView {
            HabitListView(habits: filteredHabits,
                          selectedFilter: $selectedFilter,
                          searchText: $searchText,
                          selection: $selection,
                          onCreate: { showingCreateSheet = true })
                .navigationTitle("Habits")
        } detail: {
            if let selection,
               let liveHabit = store.habit(id: selection.id) {
                HabitDetailView(habitID: liveHabit.id)
            } else {
                EmptyStateView(title: "Select a Habit",
                               systemImage: "list.bullet.rectangle",
                               message: "Choose or create a habit to see its details.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            NavigationStack {
                HabitEditorView(mode: .new) { result in
                    if case let .success(habit) = result {
                        store.add(habit)
                        selection = habit
                    }
                    showingCreateSheet = false
                }
            }
            .presentationDetents([.medium, .large])
        }
        .task {
            await store.load()
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
        }
        .navigationDestination(for: Habit.self) { habit in
            HabitDetailView(habitID: habit.id)
        }
    }

    private var addButton: some View {
        Button(action: { showingCreateSheet = true }) {
            Label("New Habit", systemImage: "plus")
                .labelStyle(.iconOnly)
                .font(.title2)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .accessibilityLabel("Create a new habit")
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitStore(sampleData: Habit.sampleData))
}
