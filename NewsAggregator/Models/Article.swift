import Foundation

struct Article: Identifiable, Equatable {
    enum Identifier: Hashable {
        case uuid(UUID)
        case url(URL)
    }

    let id: Identifier
    let title: String
    let summary: String
    let author: String?
    let source: NewsSource
    let url: URL
    let imageURL: URL?
    let publishedAt: Date
    let category: NewsCategory

    init(
        id: Identifier = .uuid(UUID()),
        title: String,
        summary: String,
        author: String? = nil,
        source: NewsSource,
        url: URL,
        imageURL: URL? = nil,
        publishedAt: Date,
        category: NewsCategory
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.author = author
        self.source = source
        self.url = url
        self.imageURL = imageURL
        self.publishedAt = publishedAt
        self.category = category
    }
}

extension Article {
    static let sample = Article(
        title: "SwiftUI makes building iOS apps delightful",
        summary: "Explore how declarative UI enables rapid development and stunning experiences across Apple platforms.",
        author: "Apple Developer",
        source: .init(name: "Developer News", homepage: URL(string: "https://developer.apple.com")!),
        url: URL(string: "https://developer.apple.com/news/" )!,
        imageURL: URL(string: "https://developer.apple.com/news/images/share.png"),
        publishedAt: Date(),
        category: .technology
    )
}
