import Foundation

// Namespace for store price models
enum StorePriceModels {
    // Model for store price
    struct StorePrice: Identifiable {
        let id = UUID()
        let store: String
        let price: String
        let onSale: Bool
        var unitPrice: String = ""
        var comparison: String = ""
        var brand: String = ""
        var fullDetails: String = ""
        
        init(store: String, price: Double, onSale: Bool = false) {
            self.store = store
            self.price = String(format: "%.2f", price)
            self.onSale = onSale
        }
        
        init(store: String, price: String, onSale: Bool = false) {
            self.store = store
            self.price = price
            self.onSale = onSale
        }
        
        init(store: String, price: String, onSale: Bool = false, unitPrice: String = "", 
             comparison: String = "", brand: String = "", fullDetails: String = "") {
            self.store = store
            self.price = price
            self.onSale = onSale
            self.unitPrice = unitPrice
            self.comparison = comparison
            self.brand = brand
            self.fullDetails = fullDetails
        }
        
        var priceFormatted: String {
            return price.hasPrefix("$") ? price : "$\(price)"
        }
        
        var numericPrice: Double {
            // Extract numeric value from price string (e.g., "$3.99" -> 3.99)
            let numericString = price.replacingOccurrences(of: "$", with: "")
            return Double(numericString) ?? 0.0
        }
    }
} 