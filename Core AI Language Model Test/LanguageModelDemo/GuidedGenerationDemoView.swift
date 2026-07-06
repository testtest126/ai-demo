//
//  GuidedGenerationDemoView.swift
//  Core AI Language Model Test
//
//  Guided generation demo: the on-device model fills a strongly-typed
//  @Generable struct instead of returning free-form text.
//

import SwiftUI
import FoundationModels

@Generable
struct TripPlan {
    @Guide(description: "A short, catchy title for the trip")
    var title: String

    @Guide(description: "The destination city")
    var destination: String

    @Guide(description: "Trip length in days", .range(1...14))
    var days: Int

    @Guide(description: "Three concrete activities", .count(3))
    var activities: [String]
}

struct GuidedGenerationDemoView: View {
    private let model = SystemLanguageModel.default

    @State private var destination = "Tokyo"
    @State private var plan: TripPlan.PartiallyGenerated?
    @State private var isGenerating = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Input") {
                    TextField("Destination", text: $destination)
                    Button(isGenerating ? "Generating…" : "Generate Trip Plan") {
                        generate()
                    }
                    .disabled(isGenerating || !model.isAvailable)
                }

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }

                if let plan {
                    Section("Structured Result") {
                        LabeledContent("Title", value: plan.title ?? "…")
                        LabeledContent("Destination", value: plan.destination ?? "…")
                        LabeledContent("Days", value: plan.days.map(String.init) ?? "…")

                        if let activities = plan.activities {
                            ForEach(Array(activities.enumerated()), id: \.offset) { _, activity in
                                Label(activity, systemImage: "checkmark.circle")
                            }
                        }
                    }
                }

                if !model.isAvailable {
                    Section {
                        Text("The on-device model is unavailable on this device.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Guided Generation")
        }
    }

    private func generate() {
        isGenerating = true
        errorMessage = nil
        plan = nil

        Task {
            defer { isGenerating = false }
            do {
                let session = LanguageModelSession(
                    instructions: "You are a travel planner. Plan realistic, fun trips."
                )
                let stream = session.streamResponse(
                    to: "Plan a trip to \(destination).",
                    generating: TripPlan.self
                )
                for try await partial in stream {
                    plan = partial.content
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

extension SystemLanguageModel {
    var isAvailable: Bool {
        if case .available = availability { return true }
        return false
    }
}

#Preview {
    GuidedGenerationDemoView()
}
