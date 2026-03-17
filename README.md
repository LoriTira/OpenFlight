# OpenFlight

A free, open-source Flighty alternative for iOS. Track your flights with real-time status, gate info, delay alerts, and Lock Screen Live Activities — without a subscription.

## Features

- **Flight Search** — Look up any flight by number with real-time data from AviationStack
- **My Flights** — Track and organize your flights (active, upcoming, past)
- **Rich Detail View** — Departure/arrival times (scheduled, estimated, actual), gates, terminals, aircraft info, delay tracking
- **Flight Progress Bar** — Visual progress indicator with airplane icon
- **Live Activities** — Track active flights on your Lock Screen and Dynamic Island
- **Offline Persistence** — SwiftData-backed storage keeps your tracked flights available offline
- **No Subscription** — Completely free. Bring your own API key (free tier available)

## Architecture

```
OpenFlightApp/
├── FlightTrackerApp.swift          # App entry point with SwiftData container
├── Models/
│   └── Flight.swift                # SwiftData model + FlightPhase enum + AirportInfo
├── Services/
│   ├── FlightService.swift         # API protocol + AviationStack implementation + mock
│   └── LiveActivityManager.swift   # ActivityKit integration
├── ViewModels/
│   └── FlightSearchViewModel.swift # Search logic and state
├── Views/
│   ├── MainTabView.swift           # Tab navigation (My Flights, Search, Settings)
│   ├── Search/
│   │   └── FlightSearchView.swift  # Search bar, results, detail sheet
│   ├── Detail/
│   │   └── FlightDetailView.swift  # Full flight detail screen
│   ├── MyFlights/
│   │   └── MyFlightsView.swift     # Tracked flights list with sections
│   ├── Settings/
│   │   └── SettingsView.swift      # API key configuration
│   └── Components/
│       ├── StatusBadge.swift        # Phase/delay status pill
│       ├── FlightProgressBar.swift  # Visual route progress
│       ├── FlightCard.swift         # Flight summary card
│       └── AirportTimeCard.swift    # Airport time/gate detail card
├── LiveActivity/
│   ├── FlightActivity.swift        # Live Activity + Dynamic Island layouts
│   └── FlightWidgetBundle.swift    # Widget bundle entry point
└── Utilities/
    ├── DateFormatting.swift         # Date/time formatting helpers
    └── Constants.swift              # App-wide constants
```

## Getting Started

1. Open the `OpenFlightApp` folder in Xcode
2. Build and run on iOS 17 or later
3. The app works immediately with mock data — no setup required

### Real Flight Data

To search real flights, get a free API key from [AviationStack](https://aviationstack.com) (100 requests/month on the free tier) and enter it in **Settings**.

## Tech Stack

- **SwiftUI** — 100% declarative UI
- **SwiftData** — Persistent storage (iOS 17+)
- **ActivityKit** — Live Activities and Dynamic Island
- **Zero dependencies** — No SPM packages, no CocoaPods, just Apple frameworks

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## License

MIT — use it however you want.
