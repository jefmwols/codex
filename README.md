# News Aggregator

A native iOS SwiftUI application that brings together the latest headlines from multiple free news sources. The experience focuses on speed, accessibility, and discoverability, offering category filters, search, and in-app article viewing.

## Features

- **Multi-source aggregation** – fetches stories from Hacker News, The Guardian (open API), and the Spaceflight News API.
- **Category filters** – quickly jump between Top Stories, Technology, Business, Science, Sports, and Culture.
- **Search** – filter articles with instant, debounced search that matches titles, summaries, or sources.
- **SwiftUI interface** – modern list layout with pull-to-refresh, inline loading/error states, and Safari presentation for reading articles.
- **Preview data** – SwiftUI previews are powered by mock providers for rapid UI iteration without hitting real APIs.

## Architecture

```
NewsAggregator/
├── Models/           // Immutable data models shared across the app
├── Services/         // Networking providers and aggregator actor
├── Utilities/        // Shared formatters and helpers
├── ViewModels/       // ObservableObject state for SwiftUI views
└── Views/            // SwiftUI screens and components
```

- `NewsViewModel` orchestrates fetching via the `NewsAggregatorService`, stores UI state, and exposes filtered articles.
- `NewsAggregatorService` fans out requests to each `NewsProviding` conformer using structured concurrency, merges results, and deduplicates articles by URL.
- Each provider (Hacker News, Guardian, Spaceflight) maps raw API responses into the shared `Article` model.

## Requirements

- Xcode 15 or newer
- iOS 17 SDK (the app targets iOS 17 and uses modern SwiftUI components like `NavigationStack` and `ContentUnavailableView`).

## Running the App

1. Open `NewsAggregator` in Xcode.
2. Select the *NewsAggregator* scheme and an iOS Simulator or device running iOS 17.
3. Build and run (`Cmd+R`).

The first launch will request articles for the "Top Stories" category. Pull down to refresh or switch categories from the leading navigation menu.

## Configuration Notes

- The Guardian API key defaults to `test`, which works for development rate limits. You can provide your own key by updating `GuardianNewsProvider.apiKey`.
- Network requests rely on public APIs without authentication (except Guardian's test key). For production, consider adding caching and more resilient error handling.

## Testing

Unit/UI tests are not yet included. Recommended next steps include isolating `NewsViewModel` with dependency injection and covering network providers with mocked URL protocols.

## Screenshots

Once you build and run the app, capture screenshots of the main list and article detail views to include in this section.
