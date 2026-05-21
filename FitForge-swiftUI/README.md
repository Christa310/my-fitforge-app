# FitForge 🐉

A Skyrim-themed fitness tracker built with SwiftUI.

## Features
- ⚔️ Character creation (Race, Class, Goal)
- 🍖 Meal & macro logging
- 📊 Nutrition tracking with macro goals
- ⚔️ Workout tracking with templates (PPL, Upper/Lower, Full Body)
- ⏱️ Rest timer (compound vs isolation)
- ⚖️ Weight tracking with chart
- 🌙 Recovery logging (sleep, soreness, energy)
- 📜 Workout history
- 🏆 Achievements system
- 🐉 Paarthurnax AI coach (powered by Claude)

## Setup

### Requirements
- Xcode 15+
- iOS 17+
- Swift 5.9+

### Running Locally
1. Open `FitForge/FitForge.xcodeproj` in Xcode
2. Select an iPhone simulator
3. Press `Cmd + R` to build and run

### Paarthurnax AI Coach
The AI coach calls the Anthropic API. To enable it:
1. Open `OtherViews.swift`
2. Find the `callPaarthurnax` function
3. Add your API key to the request headers:
   ```swift
   request.setValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
   ```

> ⚠️ Never commit your API key to GitHub. Use environment variables or a secrets manager.

## Project Structure
```
FitForge/
├── FitForgeApp.swift          # App entry point
├── Models/
│   ├── Models.swift           # All data models & static data
│   └── AppStore.swift         # Central state management
└── Views/
    ├── Theme.swift            # Colors, reusable components
    ├── CharacterCreationView.swift
    ├── MainTabView.swift
    ├── DashboardView.swift
    ├── MealsView.swift
    ├── WorkoutView.swift
    └── OtherViews.swift       # Weight, Nutrition, Recovery, History, Coach
```

## CI/CD
GitHub Actions automatically builds and tests the app on every push to `main`.
See `.github/workflows/ios.yml`.
