//
//  RootTabView.swift
//  Core AI Language Model Test
//
//  Root navigation: language model demos plus the SwiftData item list.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Chat", systemImage: "bubble.left.and.text.bubble.right") {
                ChatDemoView()
            }
            Tab("Guided", systemImage: "list.bullet.rectangle") {
                GuidedGenerationDemoView()
            }
            Tab("Profiles", systemImage: "sparkles") {
                DynamicProfileDemoView()
            }
            Tab("Items", systemImage: "clock") {
                ContentView()
            }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: Item.self, inMemory: true)
}
