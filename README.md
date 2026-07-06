# Core AI Language Model Test

A multiplatform Apple app for experimenting with on-device AI language models. Built with SwiftUI and SwiftData, targeting iOS, macOS, and visionOS from a single codebase.

## Platforms

| Platform | Minimum Version |
|----------|-----------------|
| iOS / iPadOS | 26.5 |
| macOS | 26.3 |
| visionOS (xrOS) | supported |

Device families: iPhone, iPad, Apple Vision Pro (`TARGETED_DEVICE_FAMILY = 1,2,7`).

## Project Structure

```
Core AI Language Model Test/
├── Core AI Language Model Test/            # App target source
│   ├── Core_AI_Language_Model_TestApp.swift  # @main entry, SwiftData ModelContainer setup
│   ├── ContentView.swift                     # SwiftData item list with platform-adaptive navigation
│   ├── Item.swift                            # SwiftData @Model (timestamped item)
│   ├── LanguageModelDemo/                    # Foundation Models framework demos
│   │   ├── RootTabView.swift                 #   Tab navigation (Chat / Guided / Items)
│   │   ├── ChatDemoView.swift                #   Streaming chat with the on-device model
│   │   └── GuidedGenerationDemoView.swift    #   Structured output via @Generable
│   ├── Info.plist                            # Background modes (remote notifications)
│   ├── Core_AI_Language_Model_Test.entitlements  # CloudKit, push notifications
│   └── Assets.xcassets/                      # App icon, accent color
├── Core AI Language Model TestTests/       # Unit tests (Swift Testing framework)
├── Core AI Language Model TestUITests/     # UI tests (XCTest)
└── Core AI Language Model Test.xcodeproj/  # Xcode project
```

## Language Model Demos

The app showcases Apple's on-device **Foundation Models** framework:

- Reference: [Adding intelligent app features with generative models](https://developer.apple.com/documentation/FoundationModels/adding-intelligent-app-features-with-generative-models)

- **Chat** (`ChatDemoView`) — streaming conversation with `LanguageModelSession.streamResponse(to:)`, session prewarming, availability handling (Apple Intelligence eligibility, model download state), and session reset.
- **Guided Generation** (`GuidedGenerationDemoView`) — structured output using `@Generable`/`@Guide`: the model fills a typed `TripPlan` struct (title, destination, days, activities) streamed as `PartiallyGenerated` snapshots.

Both demos degrade gracefully when the model is unavailable. Running them requires a device/OS with Apple Intelligence enabled.

## Architecture

- **UI**: SwiftUI. `RootTabView` hosts three tabs: the two language-model demos and the SwiftData item list. `ContentView` renders a `List` of items; a `NavigationViewWrapper` adapts navigation per platform (`NavigationSplitView` on macOS, plain content elsewhere). Platform-specific toolbar items via `#if os(...)` conditionals.
- **AI**: FoundationModels. `SystemLanguageModel.default` with availability checks; `LanguageModelSession` for streaming chat and guided generation of `@Generable` types.
- **Persistence**: SwiftData. `Item` is the single `@Model`; the app configures a shared `ModelContainer` at launch (persistent, not in-memory).
- **Capabilities**: CloudKit (iCloud services) and remote push notifications (`aps-environment: development`, `remote-notification` background mode) — groundwork for cloud sync.

## Targets & Schemes

| Target | Purpose |
|--------|---------|
| `Core AI Language Model Test` | Main app |
| `Core AI Language Model TestTests` | Unit tests — uses the **Swift Testing** framework (`@Test`, `#expect`) |
| `Core AI Language Model TestUITests` | UI tests — uses XCTest |

Single shared scheme: `Core AI Language Model Test`.

## Building

Requires Xcode with the appropriate platform SDKs.

```sh
# Build for macOS
xcodebuild -project "Core AI Language Model Test.xcodeproj" \
  -scheme "Core AI Language Model Test" \
  -destination "platform=macOS" build

# Build for iOS Simulator
xcodebuild -project "Core AI Language Model Test.xcodeproj" \
  -scheme "Core AI Language Model Test" \
  -destination "generic/platform=iOS Simulator" build

# Run tests
xcodebuild -project "Core AI Language Model Test.xcodeproj" \
  -scheme "Core AI Language Model Test" \
  -destination "platform=macOS" test
```

Or open the project in Xcode and press ⌘R.

## Notes

- Bundle identifier: `private.Core-AI-Language-Model-Test`
- Swift language version: 5.0 (Xcode toolchain)
- The Items tab retains the SwiftData starter template — a timestamped item list with add/delete — alongside the Foundation Models demos.
