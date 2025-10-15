import SwiftUI

@main
struct NewsAggregatorApp: App {
    @StateObject private var viewModel = NewsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
