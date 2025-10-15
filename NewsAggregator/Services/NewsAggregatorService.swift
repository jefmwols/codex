import Foundation

actor NewsAggregatorService {
    private let providers: [any NewsProviding]

    init(providers: [any NewsProviding] = [HackerNewsProvider(), GuardianNewsProvider(), SpaceflightNewsProvider()]) {
        self.providers = providers
    }

    func fetchArticles(category: NewsCategory?, query: String?) async throws -> [Article] {
        enum ProviderResult {
            case success([Article])
            case failure(NewsServiceError)
        }

        return try await withTaskGroup(of: ProviderResult.self, returning: [Article].self) { group in
            for provider in providers where category.map(provider.supports) ?? true {
                group.addTask {
                    do {
                        let articles = try await provider.fetchArticles(category: category, query: query)
                        return .success(articles)
                    } catch let error as NewsServiceError {
                        return .failure(error)
                    } catch {
                        return .failure(.requestFailed(error))
                    }
                }
            }

            var collected: [Article] = []
            var failures: [NewsServiceError] = []

            for await result in group {
                switch result {
                case .success(let articles):
                    collected.append(contentsOf: articles)
                case .failure(let error):
                    failures.append(error)
                }
            }

            guard !collected.isEmpty else {
                if let firstFailure = failures.first {
                    throw firstFailure
                }
                throw NewsServiceError.noArticlesFound
            }

            let unique = Dictionary(grouping: collected, by: { $0.url })
                .compactMap { $0.value.sorted { $0.publishedAt > $1.publishedAt }.first }
                .sorted { $0.publishedAt > $1.publishedAt }

            return unique
        }
    }
}
