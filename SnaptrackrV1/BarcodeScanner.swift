import SwiftUI
import Foundation
import AVFoundation

// Service for product lookup
class ProductLookupService {
    static let shared = ProductLookupService()
    
    private init() {}
    
    func lookupProduct(barcode: String, store: String, completion: @escaping (Result<ProductInfo, Error>) -> Void) {
        // Use Google Sheets service to look up the product
        GoogleSheetsService.shared.lookupProductByBarcode(barcode: barcode, store: store) { result in
            switch result {
            case .success(let sheetProductInfo):
                // Product found in Google Sheets, now get the weblink from Perplexity if needed
                if sheetProductInfo.link.isEmpty {
                    // If no link in Google Sheets, use Perplexity to get one
                    PerplexityService.shared.getWeblink(for: sheetProductInfo.item) { weblinkResult in
                        switch weblinkResult {
                        case .success(let weblink):
                            // Create product info with the retrieved weblink
                            let product = ProductInfo(
                                name: sheetProductInfo.item,
                                category: sheetProductInfo.category,
                                price: sheetProductInfo.numericPrice,
                                barcode: barcode,
                                weblink: weblink,
                                pricePerUnit: sheetProductInfo.pricePerUnit
                            )
                            completion(.success(product))
                            
                        case .failure(let error):
                            // Use the product info without a weblink
                            let product = ProductInfo(
                                name: sheetProductInfo.item,
                                category: sheetProductInfo.category,
                                price: sheetProductInfo.numericPrice,
                                barcode: barcode,
                                weblink: "",
                                pricePerUnit: sheetProductInfo.pricePerUnit
                            )
                            completion(.success(product))
                            print("Warning: Could not retrieve weblink: \(error)")
                        }
                    }
                } else {
                    // Use the link from Google Sheets
                    let product = ProductInfo(
                        name: sheetProductInfo.item,
                        category: sheetProductInfo.category,
                        price: sheetProductInfo.numericPrice,
                        barcode: barcode,
                        weblink: sheetProductInfo.link,
                        pricePerUnit: sheetProductInfo.pricePerUnit
                    )
                    completion(.success(product))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Service for price comparison
class PriceComparisonService {
    static let shared = PriceComparisonService()
    
    private init() {}
    
    func getComparisonPrices(for productName: String, stores: [String], completion: @escaping (Result<[StorePriceModels.StorePrice], Error>) -> Void) {
        // In a real app, this would call APIs to get prices from different stores
        // For now, we'll simulate with mock data
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            var prices: [StorePriceModels.StorePrice] = []
            
            // Generate random prices for each store
            for store in stores {
                let basePrice = Double.random(in: 1.99...15.99)
                let onSale = Bool.random()
                prices.append(StorePriceModels.StorePrice(store: store, price: basePrice, onSale: onSale))
            }
            
            completion(.success(prices))
        })
    }
}

// Store for price comparison data
class PriceComparisonStore: ObservableObject {
    static let shared = PriceComparisonStore()
    
    @Published var comparisons: [String: [StorePriceModels.StorePrice]] = [:]
    
    private init() {}
    
    func saveComparisons(productName: String, prices: [StorePriceModels.StorePrice]) {
        comparisons[productName] = prices
    }
}

// Model for product information
struct ProductInfo {
    let name: String
    let category: String
    let price: Double
    let barcode: String
    let weblink: String
    let pricePerUnit: String
    
    init(name: String, category: String, price: Double, barcode: String, weblink: String = "", pricePerUnit: String = "") {
        self.name = name
        self.category = category
        self.price = price
        self.barcode = barcode
        self.weblink = weblink
        self.pricePerUnit = pricePerUnit
    }
}

// Barcode scanner view
struct BarcodeScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var inventoryManager = InventoryManager.shared
    @State private var isProcessing = false
    @State private var scanResult: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedStore = "Walmart" // Default store
    @State private var availableStores: [String] = []
    @State private var showStoreSelection = false
    
    var body: some View {
        ZStack {
            // Camera view would go here
            // For now, we'll use a placeholder
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Store selection button
                Button(action: {
                    showStoreSelection = true
                }) {
                    HStack {
                        Text("Store: \(selectedStore)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(10)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Scan frame
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.white, lineWidth: 3)
                    .frame(width: 250, height: 250)
                    .overlay(
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 100))
                            .foregroundColor(.white.opacity(0.5))
                    )
                
                Spacer()
                
                // Scan button
                Button(action: {
                    // Simulate scanning a barcode
                    // For demo purposes, we'll use barcodes that end with 123, 456, or 789
                    // to match our mock data in GoogleSheetsService
                    let mockBarcodes = ["123456123", "987654456", "456789789"]
                    let mockBarcode = mockBarcodes.randomElement() ?? "123456123"
                    processBarcodeScan(barcode: mockBarcode)
                }) {
                    Text("Scan Barcode")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 50)
            }
            
            // Loading indicator
            if isProcessing {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Scan Result"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .actionSheet(isPresented: $showStoreSelection) {
            ActionSheet(
                title: Text("Select Store"),
                buttons: availableStores.map { store in
                    .default(Text(store)) {
                        selectedStore = store
                    }
                } + [.cancel()]
            )
        }
        .onAppear {
            // Load available stores
            loadAvailableStores()
        }
    }
    
    func loadAvailableStores() {
        GoogleSheetsService.shared.getAvailableStores { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let stores):
                    self.availableStores = stores
                case .failure(let error):
                    print("Error loading stores: \(error)")
                    // Use default stores if loading fails
                    self.availableStores = ["Walmart","Trader Joe's", "Costco", "Whole Foods"]
                }
            }
        }
    }
    
    func processBarcodeScan(barcode: String) {
        // First check if we already have this item
        if let existingItem = inventoryManager.groceryItems.first(where: { $0.barcode == barcode }) {
            // We already have this item, just update quantity
            var updatedItem = existingItem
            updatedItem.quantity += 1
            // Note: You need to implement this method in InventoryManager
            inventoryManager.updateItem(updatedItem)
            
            alertMessage = "Added another \(existingItem.name)"
            showAlert = true
            return
        }
        
        // Otherwise, look up the product info
        isProcessing = true
        
        // Use the updated ProductLookupService to get product details from Google Sheets
        ProductLookupService.shared.lookupProduct(barcode: barcode, store: selectedStore) { result in
            DispatchQueue.main.async(execute: {
                self.isProcessing = false
                
                switch result {
                case .success(let product):
                    // Create a new grocery item with the fetched data
                    let newItem = GroceryItem(
                        name: product.name,
                        category: product.category,
                        price: product.price,
                        quantity: 1,
                        barcode: barcode,
                        dateAdded: Date(),
                        imageData: nil,
                        weblink: product.weblink,
                        pricePerUnit: product.pricePerUnit
                    )
                    
                    // Add to inventory
                    self.inventoryManager.addItem(newItem)
                    
                    // Also fetch comparison prices for this product
                    self.fetchComparisonPrices(for: product.name)
                    
                    self.alertMessage = "Added \(product.name) to inventory"
                    self.showAlert = true
                    
                case .failure(let error):
                    if let sheetsError = error as? GoogleSheetsService.GoogleSheetsError {
                        switch sheetsError {
                        case .storeNotFound:
                            self.alertMessage = "Store '\(self.selectedStore)' not found in database."
                        case .itemNotFound:
                            self.alertMessage = "Item with barcode '\(barcode)' not found in \(self.selectedStore)."
                        default:
                            self.alertMessage = "Error looking up product: \(sheetsError)"
                        }
                    } else {
                        self.alertMessage = "Could not identify product. Please try again."
                    }
                    self.showAlert = true
                }
            })
        }
    }
    
    func fetchComparisonPrices(for productName: String) {
        // This would call your price comparison service
        PriceComparisonService.shared.getComparisonPrices(
            for: productName,
            stores: availableStores
        ) { result in
            DispatchQueue.main.async(execute: {
                switch result {
                case .success(let prices):
                    // Store these prices for use in the Compare tab
                    PriceComparisonStore.shared.saveComparisons(
                        productName: productName,
                        prices: prices
                    )
                case .failure(let error):
                    print("Error fetching comparison prices: \(error)")
                }
            })
        }
    }
} 
