import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct HackerNewsProvider: NewsProviding {
    let source = NewsSource(name: "Hacker News", homepage: URL(string: "https://news.ycombinator.com")!)

    func supports(category: NewsCategory) -> Bool {
        switch category {
        case .technology, .science, .top:
            return true
        default:
            return false
        }
    }

    func fetchArticles(category: NewsCategory?, query: String?) async throws -> [Article] {
        var components = URLComponents(string: "https://hn.algolia.com/api/v1/search_by_date")!
        var queryItems = [URLQueryItem(name: "tags", value: "story")]
        if let query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        components.queryItems = queryItems

        let (data, response) = try await URLSession.shared.data(from: components.url!, delegate: nil)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NewsServiceError.invalidResponse
        }

        do {
            let decoded = try JSONDecoder.hackerNewsDecoder.decode(HackerNewsResponse.self, from: data)
            return decoded.hits.compactMap { $0.article(using: source) }
        } catch {
            throw NewsServiceError.decodingFailed(error)
        }
    }
}

private struct HackerNewsResponse: Decodable {
    let hits: [Hit]

    struct Hit: Decodable {
        let title: String?
        let storyText: String?
        let url: String?
        let author: String?
        let createdAt: Date

        enum CodingKeys: String, CodingKey {
            case title
            case storyText = "story_text"
            case url
            case author
            case createdAt = "created_at"
        }

        func article(using source: NewsSource) -> Article? {
            guard let title, let urlString = url, let url = URL(string: urlString) else { return nil }
            let summary = storyText ?? ""
            return Article(
                id: .url(url),
                title: title,
                summary: summary.isEmpty ? "Read the full story on Hacker News." : summary,
                author: author,
                source: source,
                url: url,
                imageURL: nil,
                publishedAt: createdAt,
                category: .technology
            )
        }
    }
}

private extension JSONDecoder {
    static let hackerNewsDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
