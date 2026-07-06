//
//  ArgumentParserDemoView.swift
//  Core AI Language Model Test
//
//  Demonstrates Apple's ArgumentParser package for structured agent command inputs.
//

import SwiftUI
import ArgumentParser

enum AgentRequestDetail: String, CaseIterable, Identifiable, ExpressibleByArgument {
    case concise
    case standard
    case detailed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .concise:
            "Concise"
        case .standard:
            "Standard"
        case .detailed:
            "Detailed"
        }
    }

    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}

struct AgentRequest: ParsableArguments {
    @Argument(help: "The task or action to perform.")
    var task: String

    @Option(name: .shortAndLong, help: "How much detail the response should include.")
    var detail: AgentRequestDetail = .standard

    @Flag(name: .shortAndLong, help: "Ask the assistant to review the result for risks.")
    var review: Bool = false

    var summary: String {
        var parts = ["Task: \(task)", "Detail: \(detail.displayName)"]
        if review {
            parts.append("Review: enabled")
        }
        return parts.joined(separator: "\n")
    }
}

struct ArgumentParserDemoView: View {
    @State private var input = "summarize --detail detailed --review"
    @State private var parsedSummary = "Try a command such as 'summarize --detail detailed --review'."
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Try a structured request") {
                    TextField("Command", text: $input, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)

                    Button("Parse request") {
                        parseInput()
                    }
                }

                Section("Parsed result") {
                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    } else {
                        Text(parsedSummary)
                            .font(.body.monospaced())
                    }
                }
            }
            .navigationTitle("Argument Parser")
            .onAppear(perform: parseInput)
        }
    }

    private func parseInput() {
        let arguments = input.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        do {
            let request = try AgentRequest.parse(arguments)
            parsedSummary = request.summary
            errorMessage = nil
        } catch {
            parsedSummary = ""
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ArgumentParserDemoView()
}
