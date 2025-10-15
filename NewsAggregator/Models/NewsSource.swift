import Foundation

struct NewsSource: Hashable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let homepage: URL

    init(id: UUID = UUID(), name: String, description: String? = nil, homepage: URL) {
        self.id = id
        self.name = name
        self.description = description
        self.homepage = homepage
    }
}

extension NewsSource {
    static let sample = NewsSource(name: "Example Source", homepage: URL(string: "https://example.com")!)
}
