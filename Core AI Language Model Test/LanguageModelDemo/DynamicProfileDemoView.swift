//
//  DynamicProfileDemoView.swift
//  Core AI Language Model Test
//
//  Dynamic profile demo for agentic app behavior: the instructions change as
//  the selected profile changes, mirroring the WWDC pattern of switching
//  context and behavior based on app state.
//

import SwiftUI
import FoundationModels

enum AgentMode: String, CaseIterable, Identifiable {
    case planner
    case reviewer
    case explainer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .planner:
            "Planner"
        case .reviewer:
            "Reviewer"
        case .explainer:
            "Explainer"
        }
    }

    var description: String {
        switch self {
        case .planner:
            "Switches the assistant into a structured planning mode."
        case .reviewer:
            "Switches the assistant into a risk-focused review mode."
        case .explainer:
            "Switches the assistant into a simple, beginner-friendly mode."
        }
    }
}

struct AgentProfile: Equatable {
    let mode: AgentMode
    let instructions: String
    let hint: String

    var description: String {
        mode.description
    }

    static func forMode(_ mode: AgentMode) -> AgentProfile {
        switch mode {
        case .planner:
            AgentProfile(
                mode: .planner,
                instructions: "You are a planning assistant. Return a compact, actionable plan with clear next steps.",
                hint: "Plan a launch checklist for a new feature."
            )
        case .reviewer:
            AgentProfile(
                mode: .reviewer,
                instructions: "You are a careful reviewer. Highlight risks, assumptions, and improvements.",
                hint: "Review this idea for risks and tradeoffs."
            )
        case .explainer:
            AgentProfile(
                mode: .explainer,
                instructions: "You are a patient explainer. Use simple language and short bullets.",
                hint: "Explain this concept to a beginner in simple terms."
            )
        }
    }
}

struct DynamicProfileDemoView: View {
    @State private var selectedMode: AgentMode = .planner
    @State private var prompt = ""
    @State private var session: LanguageModelSession
    @State private var messages: [ChatMessage] = []
    @State private var errorMessage: String?

    init() {
        let profile = AgentProfile.forMode(.planner)
        _session = State(initialValue: LanguageModelSession(instructions: profile.instructions))
    }

    private var activeProfile: AgentProfile {
        AgentProfile.forMode(selectedMode)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(activeProfile.mode.title)
                        .font(.headline)
                    Text(activeProfile.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Example: \(activeProfile.hint)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top])

                Picker("Profile", selection: $selectedMode) {
                    ForEach(AgentMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedMode) { _, newValue in
                    let profile = AgentProfile.forMode(newValue)
                    session = LanguageModelSession(instructions: profile.instructions)
                    session.prewarm()
                    messages.removeAll()
                    errorMessage = nil
                }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if messages.isEmpty {
                            ContentUnavailableView(
                                "Switch profiles",
                                systemImage: "sparkles",
                                description: Text("Try a different profile to change the assistant’s tone and behavior.")
                            )
                            .padding(.top, 24)
                        }

                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }

                        if let errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                }

                Divider()

                HStack(spacing: 8) {
                    TextField("Ask the agent…", text: $prompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                        .onSubmit(send)

                    Button("Send") {
                        send()
                    }
                    .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || session.isResponding)
                }
                .padding()
            }
            .navigationTitle("Dynamic Profiles")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        let profile = AgentProfile.forMode(selectedMode)
                        session = LanguageModelSession(instructions: profile.instructions)
                        session.prewarm()
                        messages.removeAll()
                        errorMessage = nil
                    }
                    .disabled(session.isResponding)
                }
            }
        }
    }

    private func send() {
        let text = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !session.isResponding else { return }

        prompt = ""
        errorMessage = nil
        messages.append(ChatMessage(role: .user, text: text))

        let assistantMessage = ChatMessage(role: .assistant, text: "")
        messages.append(assistantMessage)

        Task {
            do {
                let stream = session.streamResponse(to: text)
                for try await partial in stream {
                    if let index = messages.firstIndex(where: { $0.id == assistantMessage.id }) {
                        messages[index].text = partial.content
                    }
                }
            } catch {
                if let index = messages.firstIndex(where: { $0.id == assistantMessage.id }) {
                    messages[index].text = ""
                }
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    DynamicProfileDemoView()
}
