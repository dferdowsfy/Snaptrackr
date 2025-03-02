import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showingScanSheet = false
    @State private var showingReceiptScanSheet = false
    @EnvironmentObject var authManager: AuthManager // Get AuthManager from the environment


    var body: some View {
        Group {
            if !authManager.isAuthenticated {
                LoginView()
                    .environmentObject(authManager) // Pass AuthManager to LoginView
            } else if !authManager.hasCompletedOnboarding {
                OnboardingView()
                    .environmentObject(authManager) // Pass AuthManager to OnboardingView
            } else {
                // Your main app content
                MainView()
                    .environmentObject(authManager) // Pass to main view.
            }
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Always check onboarding status when authentication changes
                authManager.updateOnboardingStatus() // This line may be redundant, but keep it for now.
            }
        }
    }

    // ... (rest of your ContentView code - no changes needed here) ...
    private var mainContentView: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(item: item)
                    } label: {
                        Text(itemDisplayText(for: item))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    private var scanMenuItems: some View {
        Group {
            Button(action: {
                showingScanSheet = true
            }) {
                Label("Scan Barcode", systemImage: "barcode.viewfinder")
            }
            
            Button(action: {
                showingReceiptScanSheet = true
            }) {
                Label("Scan Receipt", systemImage: "doc.text.viewfinder")
            }
        }
    }
    
    private func itemDisplayText(for item: Item) -> String {
        return item.title ?? "Item at \(item.timestamp.formatted(date: .numeric, time: .standard))"
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}
