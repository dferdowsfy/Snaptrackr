import SwiftUI

struct ModernMainView: View {
    @State private var selectedTab = 0
    @StateObject private var authManager = AuthManager.shared
    @State private var showLoginView = false
    
    // Scanner states
    @State private var showBarcodeScanner = false
    @State private var showReceiptScanner = false
    @State private var showProductScanner = false
    @State private var showManualEntry = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 68/255, green: 36/255, blue: 164/255),
                    Color(red: 84/255, green: 212/255, blue: 228/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Tab content
                TabView(selection: $selectedTab) {
                    // Home tab
                    HomeView()
                        .tag(0)
                    
                    // Inventory tab (formerly Shopping List)
                    ShoppingListView()
                        .tag(1)
                    
                    // Analytics tab
                    AnalyticsView()
                        .tag(2)
                    
                    // Profile tab
                    ProfileView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer() // Add spacer to push nav bar to bottom
                
                // Modern tab bar
                ModernTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 2)
            }
            
            // Chatbot bubble overlay
            ChatbotBubble()
        }
        .safeAreaInset(edge: .bottom) { // Add safe area inset for bottom
            Color.clear.frame(height: 0)
        }
        .onAppear {
            // Check if user is logged in
            if !authManager.isAuthenticated {
                // If not logged in, show login view
                showLoginView = true
            }
        }
        .onChange(of: authManager.isAuthenticated) { newValue in
            // Update showLoginView when authentication status changes
            showLoginView = !newValue
        }
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
        }
        // Scanner sheets
        .sheet(isPresented: $showReceiptScanner) {
            ReceiptProcessingView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showBarcodeScanner) {
            Text("Barcode Scanner")
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 68/255, green: 36/255, blue: 164/255),
                            Color(red: 84/255, green: 212/255, blue: 228/255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .sheet(isPresented: $showProductScanner) {
            Text("Product Scanner")
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 68/255, green: 36/255, blue: 164/255),
                            Color(red: 84/255, green: 212/255, blue: 228/255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .sheet(isPresented: $showManualEntry) {
            Text("Manual Entry")
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 68/255, green: 36/255, blue: 164/255),
                            Color(red: 84/255, green: 212/255, blue: 228/255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenBarcodeScanner"))) { _ in
            showBarcodeScanner = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenReceiptScanner"))) { _ in
            showReceiptScanner = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenProductScanner"))) { _ in
            showProductScanner = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenManualEntry"))) { _ in
            showManualEntry = true
        }
    }
}

struct ModernMainView_Previews: PreviewProvider {
    static var previews: some View {
        ModernMainView()
    }
} 
