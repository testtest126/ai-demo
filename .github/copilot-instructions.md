# Copilot Instructions

Multiplatform (iOS/macOS/visionOS) SwiftUI + SwiftData app demonstrating Apple's on-device FoundationModels framework. See [README.md](../README.md) for the full overview.

## Conventions
- New Swift files under `Core AI Language Model Test/` are auto-included via Xcode synchronized folders — never edit `project.pbxproj` to add files.
- Language-model demos live in `Core AI Language Model Test/LanguageModelDemo/`; each demo is a self-contained SwiftUI view with a tab in `RootTabView`.
- Always check `SystemLanguageModel.default.availability` before using the model; degrade gracefully (`ContentUnavailableView`), never crash on generation errors.
- Use platform conditionals (`#if os(...)`) for platform-specific UI; the app must keep compiling for iOS, macOS, and visionOS.
- Unit tests use Swift Testing (`@Test`, `#expect`); UI tests use XCTest.

## Build & Verify
CLI builds must disable code signing (no local dev certificate):

```sh
xcodebuild -project "Core AI Language Model Test.xcodeproj" \
  -scheme "Core AI Language Model Test" \
  -destination "platform=macOS" \
  build CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" -quiet
```

Details: `.github/skills/xcode-build-test/`. FoundationModels API patterns: `.github/skills/foundation-models/`.
