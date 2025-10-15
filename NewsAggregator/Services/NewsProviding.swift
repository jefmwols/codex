import Foundation

protocol NewsProviding {
    var source: NewsSource { get }
    func supports(category: NewsCategory) -> Bool
    func fetchArticles(category: NewsCategory?, query: String?) async throws -> [Article]
}

enum NewsServiceError: Error, LocalizedError {
    case invalidResponse
    case requestFailed(Error)
    case decodingFailed(Error)
    case noArticlesFound

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The news service returned an unexpected response."
        case .requestFailed(let error):
            return "Unable to load news right now: \(error.localizedDescription)."
        case .decodingFailed:
            return "The news data could not be decoded."
        case .noArticlesFound:
            return "We couldn't find any stories right now."
        }
    }
}
