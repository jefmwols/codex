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

    enum Schedule: String, CaseIterable, Codable, Identifiable {
        case daily
        case weekly
        case weekdays
        case weekends
        case monthly

        var id: String { rawValue }

        var title: String {
            switch self {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .weekdays: return "Weekdays"
            case .weekends: return "Weekends"
            case .monthly: return "Monthly"
            }
        }

        var description: String {
            switch self {
            case .daily: return "Every day"
            case .weekly: return "Once each week"
            case .weekdays: return "Monday through Friday"
            case .weekends: return "Saturday and Sunday"
            case .monthly: return "Once each month"
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
    var schedule: Schedule = .daily
    var createdAt: Date
    var dueAt: Date?
    var completedAt: Date?
    var notes: String

    init(id: UUID = UUID(),
         title: String,
         summary: String = "",
         status: Status = .planned,
         category: Category = .productivity,
         schedule: Schedule = .daily,
         createdAt: Date = .now,
         dueAt: Date? = nil,
         completedAt: Date? = nil,
         notes: String = "") {
        self.id = id
        self.title = title
        self.summary = summary
        self.status = status
        self.category = category
        self.schedule = schedule
        self.createdAt = createdAt
        self.dueAt = dueAt
        self.completedAt = completedAt
        self.notes = notes
    }
}

extension Habit {
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case summary
        case status
        case category
        case schedule
        case createdAt
        case dueAt
        case completedAt
        case notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        status = try container.decode(Status.self, forKey: .status)
        category = try container.decode(Category.self, forKey: .category)
        schedule = try container.decodeIfPresent(Schedule.self, forKey: .schedule) ?? .daily
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        dueAt = try container.decodeIfPresent(Date.self, forKey: .dueAt)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        notes = try container.decode(String.self, forKey: .notes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(summary, forKey: .summary)
        try container.encode(status, forKey: .status)
        try container.encode(category, forKey: .category)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(dueAt, forKey: .dueAt)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encode(notes, forKey: .notes)
    }
}

extension Habit {
    static let sampleData: [Habit] = [
        Habit(title: "Ship design update",
              summary: "Polish the v2 mockups and gather feedback from design review.",
              status: .inProgress,
              category: .productivity,
              schedule: .weekdays,
              createdAt: .now.addingTimeInterval(-86_400 * 2),
              dueAt: .now.addingTimeInterval(86_400 * 2),
              notes: "Pair with Alex on the accessibility checks."),
        Habit(title: "Take a mindful walk",
              summary: "30 minute walk without headphones.",
              status: .planned,
              category: .wellness,
              schedule: .daily,
              createdAt: .now,
              dueAt: .now.addingTimeInterval(86_400),
              notes: "Invite a teammate to join."),
        Habit(title: "Finish SwiftUI tutorial",
              summary: "Complete the chapter on navigation and data flow.",
              status: .completed,
              category: .learning,
              schedule: .weekly,
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
