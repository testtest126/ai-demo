---
name: foundation-models
description: 'Work with Apple Foundation Models framework (on-device LLM) in this project. Use when: adding language model features, writing LanguageModelSession code, streaming responses, guided generation with @Generable/@Guide, handling model availability, or extending the chat and guided generation demos.'
---

# Foundation Models Framework

## When to Use
- Add or modify on-device language model features
- Extend [ChatDemoView](../../../Core%20AI%20Language%20Model%20Test/LanguageModelDemo/ChatDemoView.swift) or [GuidedGenerationDemoView](../../../Core%20AI%20Language%20Model%20Test/LanguageModelDemo/GuidedGenerationDemoView.swift)

## Core Patterns

### Availability — always check first
```swift
let model = SystemLanguageModel.default
switch model.availability {
case .available: // show feature
case .unavailable(let reason): // .deviceNotEligible, .appleIntelligenceNotEnabled, .modelNotReady
}
```
Always include `@unknown default` when switching on `UnavailableReason`.

### Sessions
```swift
let session = LanguageModelSession(instructions: "You are a concise assistant.")
session.prewarm() // call early to reduce first-token latency
```
- One session = one conversation; it accumulates a transcript.
- Check `session.isResponding` before sending; a session handles one request at a time.
- To reset a conversation, create a new session (assign to `@State`).

### Streaming text
```swift
let stream = session.streamResponse(to: prompt)
for try await partial in stream {
    text = partial.content // cumulative snapshot, not a delta
}
```

### Guided generation
```swift
@Generable
struct TripPlan {
    @Guide(description: "Trip length in days", .range(1...14))
    var days: Int
    @Guide(description: "Three concrete activities", .count(3))
    var activities: [String]
}

let stream = session.streamResponse(to: prompt, generating: TripPlan.self)
for try await partial in stream {
    plan = partial.content // TripPlan.PartiallyGenerated — all fields Optional
}
```
- `PartiallyGenerated` mirrors the struct with optional fields; UI must handle `nil` per field.
- Non-streaming alternative: `try await session.respond(to:generating:).content`.

## Project Conventions
- Demos live in `Core AI Language Model Test/LanguageModelDemo/`.
- New demo views get a tab in [RootTabView](../../../Core%20AI%20Language%20Model%20Test/LanguageModelDemo/RootTabView.swift).
- Wrap model errors into user-visible messages (`error.localizedDescription`); never crash on generation failure.
- Degrade gracefully with `ContentUnavailableView` when the model is unavailable.

## Constraints
- On-device model: small context window, keep prompts and instructions short.
- Runtime requires Apple Intelligence-capable hardware; code compiles anywhere with current SDKs.
- Simulator/preview availability varies — never assume `.available`.
