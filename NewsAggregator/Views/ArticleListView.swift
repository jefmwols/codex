import SwiftUI

struct ArticleListView: View {
    @EnvironmentObject private var viewModel: NewsViewModel
    @State private var presentingArticle: Article?

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingView()
            case .loaded:
                content
            case .failed(let message):
                ErrorView(message: message) {
                    Task { await viewModel.refresh(force: true) }
                }
            }
        }
        .sheet(item: $presentingArticle) { article in
            SafariView(url: article.url)
        }
    }

    private var content: some View {
        let articles = viewModel.filteredArticles()
        return VStack(spacing: 0) {
            SearchBarView(query: $viewModel.searchQuery) { newValue in
                viewModel.onSearchChanged(newValue)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            if articles.isEmpty {
                Group {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "No stories",
                            systemImage: "newspaper",
                            description: Text("Try another category or search term.")
                        )
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "newspaper")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No stories")
                                .font(.headline)
                            Text("Try another category or search term.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List(articles) { article in
                    ArticleRowView(article: article)
                        .contentShape(Rectangle())
                        .onTapGesture { presentingArticle = article }
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    ArticleListView()
        .environmentObject(NewsViewModel.preview)
}
