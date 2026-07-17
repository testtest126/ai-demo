# AGENTS.md

<!--
  The single source of truth for how AI agents (and humans) work in this repo.
  Many tools read it — Claude Code, GitHub Copilot, and more. Keep it accurate;
  it's the first thing an agent should read before touching source.
-->

## What this project is
**Core AI Language Model Test** is a multiplatform Apple app (iOS/iPadOS,
macOS, visionOS — single codebase) demonstrating Apple's on-device
**Foundation Models** framework: streaming chat, guided generation
(`@Generable`/`@Guide`), a `swift-argument-parser`-based structured-command
demo, and a dynamic agent-profile demo, alongside a SwiftData starter item
list. Built with SwiftUI + SwiftData. See `README.md` for the full
architecture writeup.

## Build, run, test
This is an Xcode project (`Core AI Language Model Test.xcodeproj`), not
XcodeGen/SPM-only — there is one shared scheme, `Core AI Language Model Test`.

**What CI actually runs** (`.github/workflows/ios.yml`, on every push/PR to
`main`): picks whatever iPhone simulator is actually provisioned on the
runner (`xcrun simctl list devices available`, not a hardcoded name — a fixed
name breaks when the runner image doesn't have that model), then:
```sh
xcodebuild build-for-testing -scheme "Core AI Language Model Test" \
  -project "Core AI Language Model Test.xcodeproj" \
  -destination "platform=iOS Simulator,name=<some available iPhone>"

xcodebuild test-without-building -scheme "Core AI Language Model Test" \
  -project "Core AI Language Model Test.xcodeproj" \
  -destination "platform=iOS Simulator,name=<some available iPhone>"
```
This is the primary source of truth for "does it build/test" — confirmed
green at commit `e513f64` (CI run
[29345188300](https://github.com/testtest126/ai-demo/actions/runs/29345188300),
`Build` and `Test` steps both `success`).

**Local CLI build** — not what CI runs, but the documented local-dev form
already established in `.github/copilot-instructions.md` and
`.github/skills/xcode-build-test/SKILL.md` (no signing certificate available
outside Xcode's UI — always pass `CODE_SIGNING_ALLOWED=NO`):
```sh
xcodebuild -project "Core AI Language Model Test.xcodeproj" \
  -scheme "Core AI Language Model Test" \
  -destination "platform=macOS" \
  build CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" -quiet
```
Swap `build` for `test` to run the same way locally. Swap the destination for
`"generic/platform=iOS Simulator"` (build) or a concrete
`"platform=iOS Simulator,name=<device>"` (test — `generic` can't run tests)
to target iOS instead of macOS. Foundation Models code compiles without
Apple Intelligence; you only need a real Apple Intelligence-enabled
device/OS to exercise it at runtime.

**Run:** open the project in Xcode and press ⌘R, or `xcodebuild ... build`
then launch the built `.app` via `xcrun simctl install` / `simctl launch`
(iOS Simulator) or directly (macOS).

> If a change is observable when the app runs, run it and confirm the
> behavior — a build/test pass alone doesn't confirm a UI fix. For UI
> changes, install and screenshot the simulator (or open Xcode) before
> calling it done.

## Project structure
```
Core AI Language Model Test/                  # App target source (Xcode "synchronized folder" — see Conventions)
├── Core_AI_Language_Model_TestApp.swift       # @main entry, SwiftData ModelContainer setup
├── ContentView.swift                          # SwiftData item list, platform-adaptive navigation
├── Item.swift                                 # SwiftData @Model
├── LanguageModelDemo/                         # Foundation Models framework demos, one per tab
│   ├── RootTabView.swift                      #   Tab navigation: Chat / Guided / Parser / Profiles / Items
│   ├── ChatDemoView.swift                     #   Streaming chat with the on-device model
│   ├── GuidedGenerationDemoView.swift         #   Structured output via @Generable/@Guide
│   ├── ArgumentParserDemoView.swift           #   swift-argument-parser structured-command demo
│   └── DynamicProfileDemoView.swift           #   Agent profile switching demo
├── Info.plist, *.entitlements                 # Background modes, CloudKit, push notifications
└── Assets.xcassets/                           # App icon (Design/app-icon.svg is the SVG master), accent color
Core AI Language Model TestTests/              # Unit tests — Swift Testing (@Test, #expect)
Core AI Language Model TestUITests/            # UI tests — XCTest
Core AI Language Model Test.xcodeproj/         # Xcode project (project.pbxproj + resolved SPM packages)
.github/
├── workflows/ios.yml                          # CI: build-for-testing + test-without-building
├── copilot-instructions.md                    # Condensed conventions (Copilot-flavored, same substance as this file)
├── skills/                                    # xcode-build-test, foundation-models — deeper how-tos
└── agents/                                    # demo-author, swift-builder — scoped agent roles
Design/app-icon.svg                            # App icon SVG master
```

## Key conventions
- **Synchronized folders, no pbxproj surgery for new files.** The app target
  uses Xcode's `PBXFileSystemSynchronizedRootGroup` — new Swift files dropped
  under `Core AI Language Model Test/` (or its subfolders) are picked up
  automatically. Don't hand-edit `project.pbxproj` to add/remove source
  files; only touch it for target-level config (package deps, build
  settings) that has no other home.
- **Foundation Models usage:** always check `SystemLanguageModel.default.availability`
  before using the model; degrade gracefully with `ContentUnavailableView`
  (never crash on generation errors, including on `.unavailable` reasons —
  include `@unknown default`). See `.github/skills/foundation-models/SKILL.md`
  for the session/streaming/guided-generation patterns this codebase follows.
- **Multiplatform:** the app targets iOS, macOS, and visionOS from one
  target (`SUPPORTED_PLATFORMS` includes all three, `TARGETED_DEVICE_FAMILY
  = 1,2,7`). Use `#if os(...)` for platform-specific UI; don't add code that
  only compiles on one platform without a conditional.
- **Tests:** unit tests use the **Swift Testing** framework (`@Test`,
  `#expect`) in `Core AI Language Model TestTests`; UI tests use **XCTest**
  in `Core AI Language Model TestUITests`.
- **SPM dependency wiring:** if a package product needs to be visible in the
  *test* target and the test target's host is the app (`TestTargetID` set),
  prefer relying on the host-app link + `import` in the test file rather
  than adding a second `packageProductDependencies` entry for the same
  product — linking the same package into both the app and its hosted test
  bundle can load two copies of the module's runtime metadata into one
  process and cause hard-to-diagnose dynamic-cast failures at runtime
  (observed firsthand while fixing `AgentRequest.parse(...)` in the test
  target — see commit `9400fa3`).
- **Dependencies:** one SPM dependency today, `swift-argument-parser`
  (pinned in `project.xcworkspace/xcshareddata/swiftpm/Package.resolved`).
  Don't add third-party dependencies for a new demo without a clear reason —
  keep the app lean (this mirrors `.github/agents/demo-author.agent.md`'s
  constraint for demo work specifically).
- **Commits:** this repo's history uses short, imperative, capitalized
  summaries (`Add MIT LICENSE`, `Fix docs link overlapping the tab bar`,
  `Restrict CI workflow token to read-only contents`) — one change per
  commit. Match that style.
- **CI permissions:** the workflow token is scoped to `contents: read`
  (least privilege) — don't broaden it without a concrete need.

## Before you edit
- Run the build (see above) after any Swift change — don't rely on
  "it should compile."
- For anything touching `LanguageModelDemo/`, read the existing demos first
  to match style, and consult `.github/skills/foundation-models/SKILL.md`.
- For build/test mechanics specifically, `.github/skills/xcode-build-test/SKILL.md`
  has the verified command forms and how to read `xcodebuild` output.
- This repo currently has **no branch protection or rulesets** on `main` (verified via
  `gh api repos/.../branches/main/protection` → 404, `gh api repos/.../rulesets` → `[]`) and PRs are optional — direct, small commits to `main` are the established
  practice here, provided CI (`Build` + `Test`) is green. That can change; if
  branch protection appears, follow it instead of this note.
- No secrets or personal data in the repo, logs, commits, or anything shared.
