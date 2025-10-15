import Foundation

enum NewsCategory: String, CaseIterable, Identifiable, Codable {
    case top
    case technology
    case business
    case science
    case sports
    case culture

    var id: String { rawValue }

    var title: String {
        switch self {
        case .top: return "Top Stories"
        case .technology: return "Technology"
        case .business: return "Business"
        case .science: return "Science"
        case .sports: return "Sports"
        case .culture: return "Culture"
        }
    }

    var iconName: String {
        switch self {
        case .top: return "globe"
        case .technology: return "desktopcomputer"
        case .business: return "chart.line.uptrend.xyaxis"
        case .science: return "atom"
        case .sports: return "sportscourt"
        case .culture: return "theatermasks"
        }
    }
}
