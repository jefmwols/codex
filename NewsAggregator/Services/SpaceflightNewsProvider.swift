import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct SpaceflightNewsProvider: NewsProviding {
    let source = NewsSource(
        name: "Spaceflight News",
        description: "Latest news about rockets, launches, and space exploration.",
        homepage: URL(string: "https://www.spaceflightnewsapi.net")!
    )

    func supports(category: NewsCategory) -> Bool {
        switch category {
        case .science, .technology, .top:
            return true
        default:
            return false
        }
    }

    func fetchArticles(category: NewsCategory?, query: String?) async throws -> [Article] {
        var components = URLComponents(string: "https://api.spaceflightnewsapi.net/v4/articles")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "ordering", value: "-published_at")
        ]

        if let query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: query))
        }

        components.queryItems = queryItems

        let (data, response) = try await URLSession.shared.data(from: components.url!, delegate: nil)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NewsServiceError.invalidResponse
        }

        do {
            let decoded = try JSONDecoder.spaceflightDecoder.decode(SpaceflightResponse.self, from: data)
            return decoded.results.map { $0.article(using: source) }
        } catch {
            throw NewsServiceError.decodingFailed(error)
        }
    }
}

private struct SpaceflightResponse: Decodable {
    let results: [ArticleItem]

    struct ArticleItem: Decodable {
        let title: String
        let summary: String
        let newsSite: String
        let url: URL
        let imageUrl: URL?
        let publishedAt: Date

        func article(using source: NewsSource) -> Article {
            Article(
                id: .url(url),
                title: title,
                summary: summary,
                author: newsSite,
                source: source,
                url: url,
                imageURL: imageUrl,
                publishedAt: publishedAt,
                category: .science
            )
        }
    }
}

private extension JSONDecoder {
    static let spaceflightDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
