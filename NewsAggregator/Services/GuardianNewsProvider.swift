import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct GuardianNewsProvider: NewsProviding {
    private static let apiKey = "test"

    let source = NewsSource(
        name: "The Guardian",
        description: "Independent journalism from around the world.",
        homepage: URL(string: "https://www.theguardian.com")!
    )

    func supports(category: NewsCategory) -> Bool {
        switch category {
        case .top, .business, .culture, .science, .sports:
            return true
        case .technology:
            return false
        }
    }

    func fetchArticles(category: NewsCategory?, query: String?) async throws -> [Article] {
        var components = URLComponents(string: "https://content.guardianapis.com/search")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "api-key", value: Self.apiKey),
            URLQueryItem(name: "show-fields", value: "trailText,thumbnail"),
            URLQueryItem(name: "order-by", value: "newest"),
            URLQueryItem(name: "page-size", value: "25")
        ]

        if let query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }

        if let category {
            queryItems.append(URLQueryItem(name: "section", value: category.guardianSection))
        }

        components.queryItems = queryItems

        let (data, response) = try await URLSession.shared.data(from: components.url!, delegate: nil)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NewsServiceError.invalidResponse
        }

        do {
            let decoded = try JSONDecoder.guardianDecoder.decode(GuardianResponse.self, from: data)
            return decoded.response.results.compactMap { $0.article(for: category, source: source) }
        } catch {
            throw NewsServiceError.decodingFailed(error)
        }
    }
}

private struct GuardianResponse: Decodable {
    let response: Response

    struct Response: Decodable {
        let results: [Result]
    }

    struct Result: Decodable {
        let id: String
        let sectionName: String
        let webTitle: String
        let webUrl: URL
        let webPublicationDate: Date
        let fields: Fields?

        struct Fields: Decodable {
            let trailText: String?
            let thumbnail: URL?
        }

        func article(for category: NewsCategory?, source: NewsSource) -> Article? {
            Article(
                id: .url(webUrl),
                title: webTitle,
                summary: fields?.trailText?.strippingHTML ?? "Read the latest from The Guardian.",
                author: nil,
                source: source,
                url: webUrl,
                imageURL: fields?.thumbnail,
                publishedAt: webPublicationDate,
                category: category ?? .top
            )
        }
    }
}

private extension JSONDecoder {
    static let guardianDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

private extension String {
    var strippingHTML: String {
        guard let data = data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return attributed?.string ?? self
    }
}

private extension NewsCategory {
    var guardianSection: String {
        switch self {
        case .top: return "news"
        case .business: return "business"
        case .culture: return "culture"
        case .science: return "science"
        case .sports: return "sport"
        case .technology: return "technology"
        }
    }
}
