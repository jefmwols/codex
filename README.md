# Codex

Habit Tracker is a native iOS application for capturing and reinforcing everyday
habits. The app is built entirely with SwiftUI and keeps your data local using
JSON persistence. It supports filtering, search, detail views, and an inline
editor so you can document context, due dates, repeating schedules (daily,
weekly, weekdays, weekends, monthly), and notes about each routine you care
about.

## Project Structure

```
HabitTracker/
├─ HabitTracker.xcodeproj/        # Xcode project
└─ HabitTracker/
   ├─ Models/                     # Data models (Habit, enums)
   ├─ ViewModels/                 # Observable stores and persistence
   ├─ Views/                      # SwiftUI screens and components
   ├─ Resources/                  # Seed JSON and launch assets
   ├─ Assets.xcassets/            # App icon and color catalog
   └─ Preview Content/            # Data for SwiftUI previews
```

## Requirements

- Xcode 15 or newer
- iOS 16.0 deployment target (runs on iPhone and iPad)

## Running the App

1. Open `HabitTracker/HabitTracker.xcodeproj` in Xcode.
2. Select the `HabitTracker` scheme and an iOS simulator or device.
3. Build and run (`⌘R`).

On first launch the app seeds a few example habits from
`Resources/SampleHabits.json`. Subsequent edits are stored locally in the
application’s documents directory.

## Next Steps

- Wire up CloudKit or another sync solution for multi-device histories.
- Add widgets or Live Activities to surface recent habits.
- Expand filtering with tags or streak analytics.

## Contributing

Pull requests are welcome. Please include context in commit messages and PR
descriptions so future readers understand the intent.

## License

Choose and document a license before sharing the project externally. Popular
choices include MIT, Apache 2.0, or GPL depending on your needs.
