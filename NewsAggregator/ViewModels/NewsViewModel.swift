import Foundation
import SwiftUI

@MainActor
final class NewsViewModel: ObservableObject {
    enum LoadingState {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var articles: [Article] = []
    @Published var selectedCategory: NewsCategory = .top {
        didSet { Task { await refresh(force: true) } }
    }
    @Published var searchQuery: String = ""
    @Published private(set) var state: LoadingState = .idle

    private let service: NewsAggregatorService
    private var searchDebounceTask: Task<Void, Never>?

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    init(service: NewsAggregatorService = NewsAggregatorService()) {
        self.service = service
    }

    func loadArticles() async {
        guard state == .idle else { return }
        await refresh(force: true)
    }

    func refresh(force: Bool = false) async {
        if !force, isLoading { return }
        state = .loading
        do {
            let fetched = try await service.fetchArticles(category: selectedCategory, query: normalizedQuery)
            withAnimation {
                articles = fetched
                state = .loaded
            }
        } catch {
            withAnimation {
                state = .failed(error.localizedDescription)
            }
        }
    }

    func onSearchChanged(_ text: String) {
        searchQuery = text
        searchDebounceTask?.cancel()
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled else { return }
            await self?.refresh(force: true)
        }
    }

    func filteredArticles() -> [Article] {
        let query = normalizedQuery
        guard !query.isEmpty else { return articles }
        return articles.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.summary.localizedCaseInsensitiveContains(query) ||
            $0.source.name.localizedCaseInsensitiveContains(query)
        }
    }

    private var normalizedQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension NewsViewModel {
    static let preview: NewsViewModel = {
        let model = NewsViewModel(service: NewsAggregatorService(providers: [PreviewNewsProvider()]))
        model.articles = PreviewNewsProvider.sampleArticles
        model.state = .loaded
        return model
    }()
}

private struct PreviewNewsProvider: NewsProviding {
    static let sampleArticles: [Article] = [
        Article.sample,
        Article(
            title: "NASA announces new lunar missions",
            summary: "Artemis program continues to expand with international partners joining the effort.",
            author: "NASA",
            source: .init(name: "NASA", homepage: URL(string: "https://www.nasa.gov")!),
            url: URL(string: "https://www.nasa.gov/news")!,
            imageURL: URL(string: "https://www.nasa.gov/sites/default/files/thumbnails/image/nasa-logo-web-rgb.png"),
            publishedAt: Date().addingTimeInterval(-7200),
            category: .science
        ),
        Article(
            title: "Markets rally after tech earnings beat expectations",
            summary: "Investors welcomed stronger-than-expected reports from major technology companies.",
            author: "Reuters",
            source: .init(name: "Reuters", homepage: URL(string: "https://www.reuters.com")!),
            url: URL(string: "https://www.reuters.com/markets")!,
            imageURL: nil,
            publishedAt: Date().addingTimeInterval(-14400),
            category: .business
        )
    ]

    var source: NewsSource { .sample }

    func supports(category: NewsCategory) -> Bool { true }

    func fetchArticles(category: NewsCategory?, query: String?) async throws -> [Article] {
        Self.sampleArticles
    }
}
