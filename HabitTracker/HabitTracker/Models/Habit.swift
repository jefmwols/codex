import Foundation

struct Habit: Identifiable, Codable, Hashable {
    enum Status: String, CaseIterable, Codable, Identifiable {
        case planned
        case inProgress = "in_progress"
        case completed

        var id: String { rawValue }

        var title: String {
            switch self {
            case .planned: return "Planned"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            }
        }

        var systemImage: String {
            switch self {
            case .planned: return "lightbulb"
            case .inProgress: return "hammer"
            case .completed: return "checkmark.circle.fill"
            }
        }
    }

    enum Category: String, CaseIterable, Codable, Identifiable {
        case productivity
        case wellness
        case learning
        case home
        case personal

        var id: String { rawValue }

        var title: String {
            rawValue.capitalized
        }

        var tint: String {
            switch self {
            case .productivity: return "blue"
            case .wellness: return "green"
            case .learning: return "purple"
            case .home: return "orange"
            case .personal: return "pink"
            }
        }
    }

    var id: UUID
    var title: String
    var summary: String
    var status: Status
    var category: Category
    var createdAt: Date
    var dueAt: Date?
    var completedAt: Date?
    var notes: String

    init(id: UUID = UUID(),
         title: String,
         summary: String = "",
         status: Status = .planned,
         category: Category = .productivity,
         createdAt: Date = .now,
         dueAt: Date? = nil,
         completedAt: Date? = nil,
         notes: String = "") {
        self.id = id
        self.title = title
        self.summary = summary
        self.status = status
        self.category = category
        self.createdAt = createdAt
        self.dueAt = dueAt
        self.completedAt = completedAt
        self.notes = notes
    }
}

extension Habit {
    static let sampleData: [Habit] = [
        Habit(title: "Ship design update",
              summary: "Polish the v2 mockups and gather feedback from design review.",
              status: .inProgress,
              category: .productivity,
              createdAt: .now.addingTimeInterval(-86_400 * 2),
              dueAt: .now.addingTimeInterval(86_400 * 2),
              notes: "Pair with Alex on the accessibility checks."),
        Habit(title: "Take a mindful walk",
              summary: "30 minute walk without headphones.",
              status: .planned,
              category: .wellness,
              createdAt: .now,
              dueAt: .now.addingTimeInterval(86_400),
              notes: "Invite a teammate to join."),
        Habit(title: "Finish SwiftUI tutorial",
              summary: "Complete the chapter on navigation and data flow.",
              status: .completed,
              category: .learning,
              createdAt: .now.addingTimeInterval(-86_400 * 5),
              completedAt: .now.addingTimeInterval(-86_400),
              notes: "Share key takeaways in #learning channel."),
    ]
}

extension Habit {
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
