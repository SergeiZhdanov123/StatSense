import SwiftUI
import SwiftData

@main
struct StatSenseApp: App {
    @StateObject private var accessibilityManager = AccessibilityManager()
    @StateObject private var graphAnalyzer = GraphAnalyzer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accessibilityManager)
                .environmentObject(graphAnalyzer)
        }
        .modelContainer(for: SavedGraph.self)
    }
}

