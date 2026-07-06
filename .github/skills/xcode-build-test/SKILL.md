---
name: xcode-build-test
description: 'Build, test, and verify the Core AI Language Model Test Xcode project from the command line. Use when: building the app, running unit or UI tests, verifying Swift code compiles, diagnosing build failures, or checking for compile errors after editing Swift files.'
---

# Xcode Build & Test

## When to Use
- Verify Swift changes compile after editing files in the app target
- Run the Swift Testing unit tests or XCTest UI tests
- Diagnose build failures

## Key Facts
- Project: `Core AI Language Model Test.xcodeproj`, single scheme: `Core AI Language Model Test`
- The project uses Xcode synchronized folders (`PBXFileSystemSynchronizedRootGroup`) — new Swift files added under the target folders are picked up automatically; no pbxproj edits needed.
- Local builds fail code signing ("No signing certificate 'Mac Development' found"). Always disable signing for CLI verification builds.

## Procedure

### Build (macOS, no signing)
```sh
xcodebuild -project "Core AI Language Model Test.xcodeproj" \
  -scheme "Core AI Language Model Test" \
  -destination "platform=macOS" \
  build CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" -quiet
```

### Build (iOS Simulator)
```sh
xcodebuild -project "Core AI Language Model Test.xcodeproj" \
  -scheme "Core AI Language Model Test" \
  -destination "generic/platform=iOS Simulator" \
  build CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" -quiet
```

### Test
```sh
xcodebuild -project "Core AI Language Model Test.xcodeproj" \
  -scheme "Core AI Language Model Test" \
  -destination "platform=macOS" \
  test CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" -quiet
```

## Interpreting Output
1. Success prints `** BUILD SUCCEEDED **` / `** TEST SUCCEEDED **`.
2. On failure, extract errors: append `2>&1 | grep -E "error:" | sort -u`.
3. `-quiet` suppresses noise; drop it only when full logs are needed.

## Notes
- Unit tests use the Swift Testing framework (`@Test`, `#expect`); UI tests use XCTest.
- Foundation Models features require Apple Intelligence at runtime, but compile without it — build verification works on any Mac with a current Xcode.
