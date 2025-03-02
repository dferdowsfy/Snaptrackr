import SwiftUI
import Foundation

struct PriceCompareView: View {
    @ObservedObject private var inventoryManager = InventoryManager.shared
    @State private var searchQuery = ""
    @State private var selectedStore = "Walmart"
    @State private var isLoadingComparisons = false
    @State private var comparePrices: [String: [StorePriceModels.StorePrice]] = [:]
    
    // List of major stores for comparison
    let stores = ["Walmart","Trader Joe's", "Costco", "Whole Foods", "Aldi"]
    
    // Store colors for visual distinction
    private let storeColors: [String: Color] = [
        "Walmart": Color(red: 0.0, green: 0.4, blue: 0.8),
        "Trader Joe's": Color(red: 0.9, green: 0.0, blue: 0.0),
        "Costco": Color(red: 0.0, green: 0.4, blue: 0.7),
        "Whole Foods": Color(red: 0.0, green: 0.6, blue: 0.3),
        "Aldi": Color(red: 0.0, green: 0.5, blue: 0.2),
    ]
    
    var filteredItems: [GroceryItem] {
        if searchQuery.isEmpty {
            return inventoryManager.groceryItems
        } else {
            return inventoryManager.groceryItems.filter { 
                $0.name.lowercased().contains(searchQuery.lowercased())
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("Price Compare")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                // Store selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Compare prices at:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(stores, id: \.self) { store in
                                Button(action: {
                                    selectedStore = store
                                }) {
                                    Text(store)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(storeColors[store] ?? Color.blue)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(selectedStore == store ? Color.white : Color.clear, lineWidth: 2)
                                        )
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("Search items...", text: $searchQuery)
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Loading indicator
                if isLoadingComparisons {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Spacer()
                    }
                    .padding()
                }
                
                // Items list with price comparisons
                VStack(spacing: 16) {
                    ForEach(filteredItems) { item in
                        ComparisonCard(
                            item: item,
                            storePrices: comparePrices[item.id.uuidString] ?? [],
                            selectedStore: selectedStore,
                            compareAction: {
                                // Compare single item
                                comparePrices(for: item)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Compare All button
                if !filteredItems.isEmpty {
                    HStack {
                        Spacer()
                        Button(action: compareAllPrices) {
                            HStack {
                                Image(systemName: "arrow.2.circlepath")
                                Text("Compare All")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
                
                if filteredItems.isEmpty {
                    VStack {
                        Image(systemName: "tag.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 20)
                        
                        Text("No items to compare")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        
                        Text("Add items to your inventory first")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                }
                
                // Add spacer to ensure content is properly padded at bottom
                Spacer(minLength: 50)
            }
            .padding(.bottom, 100) // Add consistent bottom padding to fix scrolling issue
        }
        .onAppear {
            // Preload comparison data if none exists
            if comparePrices.isEmpty && !inventoryManager.groceryItems.isEmpty {
                compareAllPrices()
            }
        }
    }
    
    // Compare prices for a single item
    func comparePrices(for item: GroceryItem) {
        isLoadingComparisons = true
        
        APIService.shared.queryPerplexityForPriceComparison(item: item.name, store: selectedStore) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // Extract price(s) from the response
                    let prices = self.extractPrices(from: response, for: self.selectedStore)
                    self.comparePrices[item.id.uuidString] = prices
                case .failure(let error):
                    print("Price comparison failed: \(error.localizedDescription)")
                }
                self.isLoadingComparisons = false
            }
        }
    }
    
    // Compare prices for all items
    func compareAllPrices() {
        guard !inventoryManager.groceryItems.isEmpty else { return }
        
        isLoadingComparisons = true
        
        // Create a group for batch processing
        let group = DispatchGroup()
        
        // Process first 5 items
        for item in inventoryManager.groceryItems.prefix(5) {
            group.enter()
            APIService.shared.queryPerplexityForPriceComparison(item: item.name, store: selectedStore) { result in
                defer { group.leave() }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        // Extract price(s) from the response
                        let prices = self.extractPrices(from: response, for: self.selectedStore)
                        self.comparePrices[item.id.uuidString] = prices
                    case .failure(let error):
                        print("Batch price comparison failed for \(item.name): \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // When all requests are complete
        group.notify(queue: .main) {
            self.isLoadingComparisons = false
        }
    }
    
    // Helper function to extract prices from text
    func extractPrices(from text: String, for store: String) -> [StorePriceModels.StorePrice] {
        // Look for price patterns
        let priceRegex = #"\$\d+(\.\d{2})?"#
        
        // Extract additional information from the API response
        let unitPricePattern = #"(\$\d+\.\d+)\s+per\s+([a-zA-Z0-9\s\.]+)"#
        let comparisonPattern = #"compared to\s+([^\.]+)"#
        let brandPattern = #"brand:\s+([^,\.]+)"#
        
        var priceString = ""
        var isOnSale = false
        var unitPrice = ""
        var comparison = ""
        var brand = ""
        
        // Extract the main price
        if let priceRange = text.range(of: priceRegex, options: .regularExpression) {
            priceString = String(text[priceRange])
            
            // Check if it's on sale
            isOnSale = text.lowercased().contains("sale") || 
                       text.lowercased().contains("discount") ||
                       text.lowercased().contains("special") ||
                       text.lowercased().contains("offer")
        }
        
        // Extract unit price if available
        if let unitPriceRange = text.range(of: unitPricePattern, options: .regularExpression) {
            let unitPriceMatch = String(text[unitPriceRange])
            unitPrice = unitPriceMatch
        }
        
        // Extract comparison information
        if let comparisonRange = text.range(of: comparisonPattern, options: .regularExpression) {
            let comparisonMatch = String(text[comparisonRange])
            comparison = comparisonMatch.replacingOccurrences(of: "compared to ", with: "")
        }
        
        // Extract brand information
        if let brandRange = text.range(of: brandPattern, options: .regularExpression) {
            let brandMatch = String(text[brandRange])
            brand = brandMatch.replacingOccurrences(of: "brand: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Create enhanced store price model with additional information
        if !priceString.isEmpty {
            return [StorePriceModels.StorePrice(
                store: store, 
                price: priceString, 
                onSale: isOnSale,
                unitPrice: unitPrice,
                comparison: comparison,
                brand: brand,
                fullDetails: text.trimmingCharacters(in: .whitespacesAndNewlines)
            )]
        }
        
        return []
    }
    
    // Function to fetch store prices
    func fetchStorePrices(for item: GroceryItem) -> [StorePriceModels.StorePrice] {
        // Implement web scraping or API calls to fetch real prices
        // This is a placeholder implementation
        let randomPrice = Double.random(in: 1.99...15.99)
        let isOnSale = Bool.random()
        return [StorePriceModels.StorePrice(store: selectedStore, price: "$\(String(format: "%.2f", randomPrice))", onSale: isOnSale)]
    }
}

// Helper function to parse store prices
func parseStorePrices(from html: String, for store: String) -> [StorePriceModels.StorePrice] {
    // Implement HTML parsing logic to extract prices from web content
    // This is a placeholder implementation
    let randomPrice = Double.random(in: 1.99...15.99)
    let isOnSale = Bool.random()
    return [StorePriceModels.StorePrice(store: store, price: "$\(String(format: "%.2f", randomPrice))", onSale: isOnSale)]
}

// Item comparison card
struct ComparisonCard: View {
    let item: GroceryItem
    let storePrices: [StorePriceModels.StorePrice]
    let selectedStore: String
    let compareAction: () -> Void
    @State private var showFullDetails = false
    
    var filteredPrices: [StorePriceModels.StorePrice] {
        storePrices.filter { $0.store == selectedStore }
    }
    
    var storePrice: StorePriceModels.StorePrice? {
        filteredPrices.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Item details
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(item.category)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Current price from inventory
                VStack(alignment: .trailing) {
                    Text("Your Price")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(item.priceFormatted)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Comparison price
            HStack {
                VStack(alignment: .leading) {
                    Text(selectedStore)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    if let price = storePrice {
                        HStack {
                            Text(price.priceFormatted)
                                .font(.headline)
                                .foregroundColor(price.onSale ? .green : .white)
                            
                            if price.onSale {
                                Text("On Sale!")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.green)
                                    .cornerRadius(4)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Show additional info from API
                        if !price.unitPrice.isEmpty {
                            Text("Unit: \(price.unitPrice)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        if !price.brand.isEmpty {
                            Text("Brand: \(price.brand)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    } else {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
                
                // Compare button - made more visible
                Button(action: compareAction) {
                    Text("Compare")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            // Full details section (expandable)
            if showFullDetails, let price = storePrice, !price.fullDetails.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    Text("Details")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(price.fullDetails)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)
            }
            
            // Show/Hide details button
            if let price = storePrice, !price.fullDetails.isEmpty {
                Button(action: {
                    withAnimation {
                        showFullDetails.toggle()
                    }
                }) {
                    HStack {
                        Text(showFullDetails ? "Hide Details" : "Show Details")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Image(systemName: showFullDetails ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// Store price row
struct StorePriceRow: View {
    let storePrice: StorePriceModels.StorePrice
    
    var body: some View {
        HStack {
            Text(storePrice.store)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(storePrice.priceFormatted)
                    .font(.headline)
                    .foregroundColor(storePrice.onSale ? .green : .white)
                
                if storePrice.onSale {
                    Text("Sale")
                        .font(.caption)
                        .padding(4)
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(4)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, 8)
    }
} 
