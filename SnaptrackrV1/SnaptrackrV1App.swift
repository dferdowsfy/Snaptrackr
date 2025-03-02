//  SnaptrackrV1App.swift
import SwiftUI
import SwiftData

@main
struct SnaptrackrV1App: App {
    // Create the SINGLE shared instance of AuthManager.  This is crucial.
    @StateObject private var authManager = AuthManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager) // Inject AuthManager into the environment
                .onAppear {
                    setupAppearance()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // Add the missing setupAppearance function
    func setupAppearance() {
        // Configure global appearance settings
        UINavigationBar.appearance().tintColor = .systemBlue
        UITableView.appearance().backgroundColor = .clear
    }
}
