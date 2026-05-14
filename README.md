# Squart iOS

Squart is a native iOS tactical board game prototype built with SwiftUI and SceneKit.

## Highlights

- Two board modes: **2D Board** and **3D Board**
- Modes: **Player vs Player** and **Player vs AI**
- AI difficulties: **Easy**, **Medium**, **Hard**
- Board setup options:
  - Sizes: 5x5, 8x8, 10x10, 12x12
  - Shapes: Square, Diamond, Circle, Triangle
  - Configurable blocker ratio
- Daily Challenge (deterministic per UTC day)
- Premium visual themes with StoreKit 2 supporter unlock
- Alternate app icon infrastructure
- Haptics and sound-effect scaffold

## Tech Stack

- Swift / SwiftUI
- SceneKit (3D board rendering)
- XCTest
- StoreKit 2

## Project Structure

- `Squart/Core` – game model and rules
- `Squart/AI` – AI engines (random, greedy, shallow minimax)
- `Squart/UI` – SwiftUI screens and components
- `Squart/Scene` – SceneKit board rendering and camera control
- `Squart/Theme` – visual theme model, palette, access rules
- `Squart/Store` – StoreKit product and entitlement management
- `Squart/Daily` – daily challenge generation and tracking
- `Squart/Utilities` – app settings, haptics, icons, helpers

## Build

Open `Squart.xcodeproj` in Xcode and run the `Squart` scheme.

CLI build example:

```bash
xcodebuild build -project Squart.xcodeproj -scheme Squart -configuration Debug -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO
```

## Tests

```bash
xcodebuild test -project Squart.xcodeproj -scheme Squart -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:SquartTests
```

## StoreKit Product

- Non-consumable: `squart.supporter`

Gameplay is fully available without purchase; supporter unlocks premium cosmetic content.
