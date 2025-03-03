import SwiftUI
import AVFoundation
import Vision
import WebKit

enum Tab {
    case dashboard, inventory, addItems, priceCompare, settings
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.bar.fill"
        case .inventory: return "cube.box.fill"
        case .addItems: return "plus.circle"
        case .priceCompare: return "magnifyingglass"
        case .settings: return "gearshape.fill"
        }
    }
    
    var title: String {
        switch self {
        case .dashboard: return "Home"
        case .inventory: return "My Stuff"
        case .addItems: return "Add Items"
        case .priceCompare: return "Search"
        case .settings: return "Settings"
        }
    }
}

struct MainView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTab: Tab = .dashboard
    @State private var showScanOptions = false
    @State private var showBarcodeScanner = false
    @State private var showReceiptScanner = false
    @State private var scannedImage: UIImage?
    @State private var scanType: ScanType = .unknown
    @State private var scannedBarcode: String?
    @State private var isProcessing = false
    @State private var showScanSuccessMessage = false
    @State private var itemsAdded = 0
    @State private var selectedStore = "Unknown Store"
    @State private var showStoreSelection = false
    
    @ObservedObject private var inventoryManager = InventoryManager.shared
    
    // List of stores for selection
    let availableStores = ["Walmart", "Trader Joe's", "Costco", "Whole Foods", "Aldi", "Target", "Kroger", "Safeway", "Unknown Store"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Updated background with new radial gradient
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 151/255, green: 41/255, blue: 200/255),
                    Color(red: 100/255, green: 10/255, blue: 300/255)
                ]),
                center: .init(x: 0.1, y: 0.2), // 10% 20%
                startRadius: 0,
                endRadius: 1000
            )
            .ignoresSafeArea()
            .ignoresSafeArea()
            
            // Content based on selected tab
            VStack {
                switch selectedTab {
                case .dashboard:
                    InventoryView()
                case .addItems:
                    // This case won't be used directly as it's handled by the scan button
                    EmptyView()
                case .inventory:
                    ShoppingListView()
                case .priceCompare:
                    PriceCompareView()
                case .settings:
                    SettingsView()
                }
            }
            
            // Processing overlay
            if isProcessing {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(2.0)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("Processing your scan...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(Color(red: 30/255, green: 36/255, blue: 164/255).opacity(0.7))
                    .cornerRadius(20)
                }
            }
            
            // Success message
            if showScanSuccessMessage {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title)
                        
                        Text("\(itemsAdded) item\(itemsAdded == 1 ? "" : "s") added to inventory!")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom))
                .onAppear {
                    // Auto-dismiss success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showScanSuccessMessage = false
                        }
                    }
                }
            }
            
            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab, showScanOptions: $showScanOptions)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .onAppear {
            // Request camera permission when view appears
            AVCaptureDevice.requestAccess(for: .video) { _ in }
            
            // Set up notification observers for scanner options
            setupNotificationObservers()
        }
        .sheet(isPresented: $showScanOptions) {
            // ScanOptionsView(
            //     showScanOptions: $showScanOptions,
            //     showBarcodeScanner: $showBarcodeScanner,
            //     showReceiptScanner: $showReceiptScanner
            // )
            // .presentationDetents([.height(200)])
        }
        .fullScreenCover(isPresented: $showBarcodeScanner) {
            ScannerView(scanType: .barcode)
        }
        .fullScreenCover(isPresented: $showReceiptScanner) {
            ScannerView(scanType: .receipt)
        }
        
        // Store selection sheet
        .actionSheet(isPresented: $showStoreSelection) {
            ActionSheet(
                title: Text("Select Store"),
                message: Text("Choose the store for this receipt"),
                buttons: availableStores.map { store in
                    .default(Text(store)) {
                        selectedStore = store
                        showReceiptScanner = true
                    }
                } + [.cancel()]
            )
        }
    }
    
    // Set up notification observers for scanner options
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("OpenBarcodeScanner"), object: nil, queue: .main) { _ in
            self.scanType = .barcode
            self.showBarcodeScanner = true
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("OpenReceiptScanner"), object: nil, queue: .main) { _ in
            self.scanType = .receipt
            self.showReceiptScanner = true
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("OpenProductScanner"), object: nil, queue: .main) { _ in
            self.scanType = .barcode
            self.showBarcodeScanner = true
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("OpenManualEntry"), object: nil, queue: .main) { _ in
            // Navigate to manual entry form
            self.selectedTab = .addItems
        }
    }
    
    private func processScannedImage(_ image: UIImage) {
        isProcessing = true
        
        // Try to detect barcode first
        detectBarcode(in: image) { barcode in
            if let barcode = barcode {
                // Barcode detected
                self.scannedBarcode = barcode
                self.scanType = .barcode
                self.processScannedData()
            } else {
                // No barcode - treat as receipt
                self.scanType = .receipt
                self.processScannedData()
            }
        }
    }
    
    // Detect barcode in image
    private func detectBarcode(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNDetectBarcodesRequest { request, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation], !results.isEmpty else {
                completion(nil)
                return
            }
            
            // Return the first barcode found
            if let barcode = results.first?.payloadStringValue {
                completion(barcode)
            } else {
                completion(nil)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            completion(nil)
        }
    }
    
    // Process the data based on scan type
    private func processScannedData() {
        print("Processing scanned data, type: \(scanType)")
        let initialCount = inventoryManager.groceryItems.count
        
        // Processing logic based on scan type
        switch scanType {
        case .barcode:
            if let barcode = scannedBarcode {
                print("Processing barcode: \(barcode)")
                
                // API call to Perplexity
                APIService.shared.queryPerplexityForBarcode(barcode) { result in
                    switch result {
                    case .success(let data):
                        print("Perplexity API success: \(data)")
                        
                        // Process the product data
                        self.inventoryManager.processBarcodeData(data, barcode: barcode)
                        
                        // Update UI
                        DispatchQueue.main.async {
                            self.isProcessing = false
                            self.itemsAdded = self.inventoryManager.groceryItems.count - initialCount
                            withAnimation {
                                self.showScanSuccessMessage = true
                                // Navigate to home screen to show the updated inventory
                                self.selectedTab = .dashboard
                            }
                        }
                        
                    case .failure(let error):
                        print("Perplexity API Error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.isProcessing = false
                        }
                    }
                }
            }
            
        case .receipt:
            if let image = scannedImage {
                print("Processing receipt image")
                
                // API call to Google Gemini
                APIService.shared.processReceiptWithGemini(image) { result in
                    switch result {
                    case .success(let data):
                        print("Google Gemini API success with data length: \(data.count)")
                        
                        // Process the receipt data with store name
                        self.inventoryManager.processReceiptData(data, storeName: self.selectedStore)
                        
                        // Update UI
                        DispatchQueue.main.async {
                            self.isProcessing = false
                            self.itemsAdded = self.inventoryManager.groceryItems.count - initialCount
                            print("Added \(self.itemsAdded) items to inventory")
                            withAnimation {
                                self.showScanSuccessMessage = true
                                // Navigate to home screen to show the updated inventory
                                self.selectedTab = .dashboard
                            }
                        }
                        
                    case .failure(let error):
                        print("Google Gemini API Error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.isProcessing = false
                        }
                    }
                }
            }
            
        case .unknown:
            print("Unknown scan type")
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }
    }
}

// Custom Tab Bar implementation with glassmorphism effect
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Binding var showScanOptions: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Glassmorphism background
            RoundedRectangle(cornerRadius: 25)
                .fill(Material.ultraThinMaterial) // Blurred transparency
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 68/255, green: 36/255, blue: 164/255).opacity(0.5),
                                    Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.3), radius: 8, x: 0, y: 0) // Soft neon glow
            
            // Tab bar content
            HStack {
                // Left side tabs
                HStack(spacing: 25) {
                    TabButton(tab: .dashboard, selectedTab: $selectedTab)
                    TabButton(tab: .inventory, selectedTab: $selectedTab)
                }
                
                // Spacer for center button
                Spacer()
                    .frame(width: 60)
                
                // Right side tabs
                HStack(spacing: 25) {
                    TabButton(tab: .priceCompare, selectedTab: $selectedTab)
                    TabButton(tab: .settings, selectedTab: $selectedTab)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 25)
            
            // Floating add button (centered and elevated)
            Button(action: {
                // Toggle scan options with animation
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showScanOptions.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 40/255, green: 20/255, blue: 100/255),
                                    Color(red: 68/255, green: 36/255, blue: 164/255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 65, height: 65)
                        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 3)
                    
                    Image(systemName: showScanOptions ? "xmark" : "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(Angle(degrees: showScanOptions ? 45 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showScanOptions)
                }
            }
            .offset(y: -30) // Move up to float above the tab bar
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 80)
        .padding(.horizontal)
    }
}

// Individual tab button with enhanced visuals
struct TabButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.7))
                    .scaleEffect(selectedTab == tab ? 1.2 : 1.0)
                    .shadow(color: selectedTab == tab ? Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.7) : .clear, radius: 5, x: 0, y: 0)
                
                Text(tab.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.7))
            }
            .frame(maxWidth: tab == .priceCompare ? 120 : nil) // Give more space for the longer title
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Camera launcher view
struct CameraLauncherView: View {
    @Binding var isPresented: Bool
    @Binding var isProcessing: Bool
    @Binding var itemsAdded: Int
    @Binding var selectedTab: Tab
    @Binding var showScanSuccessMessage: Bool
    @State private var scannedImage: UIImage?
    @State private var scannedBarcode: String?
    @State private var scanType: ScanType = .unknown
    let selectedStore: String
    let inventoryManager: InventoryManager
    
    var body: some View {
        // Use UIImagePickerController as a simpler alternative that avoids device-specific camera issues
        ImagePicker(isPresented: $isPresented, image: $scannedImage)
            .edgesIgnoringSafeArea(.all)
            .onDisappear {
                if let image = scannedImage {
                    // Process the image here
                    processImage(image)
                }
            }
    }
    
    func processImage(_ image: UIImage) {
        // Reset state
        isProcessing = true
        itemsAdded = 0
        
        // Store initial count to calculate items added
        let initialCount = inventoryManager.groceryItems.count
        
        // Determine scan type (barcode or receipt)
        // For now, we'll just assume it's a receipt
        // In a real app, you'd use image recognition to detect barcodes
        scanType = .receipt
        
        // Process based on scan type
        switch scanType {
        case .barcode:
            // Process barcode (not implemented in this example)
            print("Barcode scanning not implemented")
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            
        case .receipt:
            if let image = scannedImage {
                print("Processing receipt image")
                
                // API call to Google Gemini
                APIService.shared.processReceiptWithGemini(image) { result in
                    switch result {
                    case .success(let data):
                        print("Google Gemini API success with data length: \(data.count)")
                        
                        // Process the receipt data with store name
                        self.inventoryManager.processReceiptData(data, storeName: self.selectedStore)
                        
                        // Update UI
                        DispatchQueue.main.async {
                            self.isProcessing = false
                            self.itemsAdded = self.inventoryManager.groceryItems.count - initialCount
                            print("Added \(self.itemsAdded) items to inventory")
                            withAnimation {
                                self.showScanSuccessMessage = true
                                // Navigate to home screen to show the updated inventory
                                self.selectedTab = .dashboard
                            }
                        }
                        
                    case .failure(let error):
                        print("Google Gemini API Error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.isProcessing = false
                        }
                    }
                }
            }
            
        case .unknown:
            print("Unknown scan type")
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }
    }
}

// Extension to convert Tab enum to Int for ModernTabBar
extension Tab {
    var intValue: Int {
        switch self {
        case .dashboard: return 0
        case .inventory: return 1
        case .priceCompare: return 2
        case .settings: return 3
        case .addItems: return 0 // Default to dashboard
        }
    }
}

// Extension to convert Int to Tab for ModernTabBar
extension Binding where Value == Tab {
    var intValue: Binding<Int> {
        Binding<Int>(
            get: {
                switch self.wrappedValue {
                case .dashboard: return 0
                case .inventory: return 1
                case .priceCompare: return 2
                case .settings: return 3
                case .addItems: return 0
                }
            },
            set: { newValue in
                switch newValue {
                case 0: self.wrappedValue = .dashboard
                case 1: self.wrappedValue = .inventory
                case 2: self.wrappedValue = .priceCompare
                case 3: self.wrappedValue = .settings
                default: self.wrappedValue = .dashboard
                }
            }
        )
    }
}

#Preview {
    MainView()
}
