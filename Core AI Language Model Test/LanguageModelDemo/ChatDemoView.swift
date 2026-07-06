//
//  ChatDemoView.swift
//  Core AI Language Model Test
//
//  Streaming chat demo for the on-device Foundation Models framework.
//

import SwiftUI
import FoundationModels

struct ChatDemoView: View {
    private let model = SystemLanguageModel.default

    @State private var session = LanguageModelSession(
        instructions: "You are a concise, helpful assistant. Keep answers short."
    )
    @State private var messages: [ChatMessage] = []
    @State private var prompt = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                switch model.availability {
                case .available:
                    chat
                case .unavailable(let reason):
                    ContentUnavailableView(
                        "Model Unavailable",
                        systemImage: "exclamationmark.brain",
                        description: Text(description(for: reason))
                    )
                }
            }
            .navigationTitle("Chat")
            .toolbar {
                ToolbarItem {
                    Button("New Session", systemImage: "arrow.counterclockwise") {
                        resetSession()
                    }
                    .disabled(session.isResponding)
                }
            }
        }
        .task { session.prewarm() }
    }

    private var chat: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                        if let errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                                .font(.callout)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.last?.text) {
                    if let lastID = messages.last?.id {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Ask the on-device model…", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(send)

                Button("Send", systemImage: "arrow.up.circle.fill") {
                    send()
                }
                .labelStyle(.iconOnly)
                .font(.title2)
                .disabled(session.isResponding || prompt.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
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
                    update(messageID: assistantMessage.id, text: partial.content)
                }
            } catch {
                update(messageID: assistantMessage.id, text: "")
                errorMessage = error.localizedDescription
            }
        }
    }

    private func update(messageID: UUID, text: String) {
        if let index = messages.firstIndex(where: { $0.id == messageID }) {
            messages[index].text = text
        }
    }

    private func resetSession() {
        messages.removeAll()
        errorMessage = nil
        session = LanguageModelSession(
            instructions: "You are a concise, helpful assistant. Keep answers short."
        )
        session.prewarm()
    }

    private func description(for reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            "This device does not support Apple Intelligence."
        case .appleIntelligenceNotEnabled:
            "Enable Apple Intelligence in Settings to use the on-device model."
        case .modelNotReady:
            "The model is downloading or not ready yet. Try again later."
        @unknown default:
            "The on-device model is unavailable."
        }
    }
}

// MARK: - Message model & bubble

struct ChatMessage: Identifiable {
    enum Role {
        case user, assistant
    }

    let id = UUID()
    let role: Role
    var text: String
}

private struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }

            Group {
                if message.text.isEmpty && message.role == .assistant {
                    ProgressView()
                } else {
                    Text(message.text)
                }
            }
            .padding(10)
            .background(
                message.role == .user ? AnyShapeStyle(.tint) : AnyShapeStyle(.quaternary),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .foregroundStyle(message.role == .user ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))

            if message.role == .assistant { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }
}

#Preview {
    ChatDemoView()
}
