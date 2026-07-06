//
//  RootTabView.swift
//  Core AI Language Model Test
//
//  Root navigation: language model demos plus the SwiftData item list.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    private let appleDocsURL = URL(string: "https://developer.apple.com/documentation/FoundationModels/adding-intelligent-app-features-with-generative-models")!

    var body: some View {
        TabView {
            Tab("Chat", systemImage: "bubble.left.and.text.bubble.right") {
                ChatDemoView()
            }
            Tab("Guided", systemImage: "list.bullet.rectangle") {
                GuidedGenerationDemoView()
            }
            Tab("Parser", systemImage: "command") {
                ArgumentParserDemoView()
            }
            Tab("Profiles", systemImage: "sparkles") {
                DynamicProfileDemoView()
            }
            Tab("Items", systemImage: "clock") {
                ContentView()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Link(destination: appleDocsURL) {
                Label("Apple Foundation Models reference", systemImage: "link")
                    .font(.footnote)
                    .foregroundStyle(.blue)
            }
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: Item.self, inMemory: true)
}
