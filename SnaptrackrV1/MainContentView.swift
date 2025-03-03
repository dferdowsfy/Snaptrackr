import SwiftUI
import SwiftData

struct MainContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        SplashScreen()
    }
}

#Preview {
    MainContentView()
        .environmentObject(AuthManager.shared)
        .modelContainer(for: Item.self)
} 