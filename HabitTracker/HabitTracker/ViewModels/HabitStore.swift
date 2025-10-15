import Foundation
import SwiftUI

@MainActor
final class HabitStore: ObservableObject {
    @Published private(set) var habits: [Habit]
    @Published var lastError: String?

    private let persistenceURL: URL

    init(sampleData: [Habit] = []) {
        self.habits = sampleData
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        self.persistenceURL = directory?.appendingPathComponent("habits.json") ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("habits.json")
    }

    func load() async {
        do {
            if FileManager.default.fileExists(atPath: persistenceURL.path) {
                let data = try Data(contentsOf: persistenceURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                habits = try decoder.decode([Habit].self, from: data)
            } else {
                try await loadSeedData()
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func add(_ habit: Habit) {
        habits.insert(habit, at: 0)
        persist()
    }

    func update(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index] = habit
        persist()
    }

    func delete(_ indexSet: IndexSet) {
        habits.remove(atOffsets: indexSet)
        persist()
    }

    func delete(ids: [Habit.ID]) {
        habits.removeAll { ids.contains($0.id) }
        persist()
    }

    func habit(id: Habit.ID) -> Habit? {
        habits.first { $0.id == id }
    }

    func filteredHabits(searchText: String, status: Habit.Status?) -> [Habit] {
        habits.filter { habit in
            let matchesStatus = status.map { habit.status == $0 } ?? true
            let matchesSearch: Bool
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch = habit.title.localizedCaseInsensitiveContains(searchText) ||
                habit.summary.localizedCaseInsensitiveContains(searchText) ||
                habit.notes.localizedCaseInsensitiveContains(searchText)
            }
            return matchesStatus && matchesSearch
        }
        .sorted { lhs, rhs in
            if lhs.status == rhs.status {
                return lhs.createdAt > rhs.createdAt
            }
            return lhs.status.sortOrder < rhs.status.sortOrder
        }
    }

    private func persist() {
        Task {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(habits)
                try data.write(to: persistenceURL, options: [.atomic])
            } catch {
                lastError = error.localizedDescription
            }
        }
    }

    private func loadSeedData() async throws {
        guard let url = Bundle.main.url(forResource: "SampleHabits", withExtension: "json") else {
            habits = Habit.sampleData
            return
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        habits = try decoder.decode([Habit].self, from: data)
    }
}

private extension Habit.Status {
    var sortOrder: Int {
        switch self {
        case .planned: return 0
        case .inProgress: return 1
        case .completed: return 2
        }
    }
}
