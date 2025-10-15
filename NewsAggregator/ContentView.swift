import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: NewsViewModel

    var body: some View {
        NavigationStack {
            ArticleListView()
                .environmentObject(viewModel)
                .navigationTitle("Top Stories")
                .toolbar { toolbarContent }
                .task { await viewModel.loadArticles() }
                .refreshable { await viewModel.refresh() }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                CategoryPickerView(selectedCategory: $viewModel.selectedCategory)
            } label: {
                Label(viewModel.selectedCategory.title, systemImage: "line.3.horizontal.decrease")
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Task { await viewModel.refresh(force: true) }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NewsViewModel.preview)
}
