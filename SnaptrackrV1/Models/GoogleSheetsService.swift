import Foundation

// Service for Google Sheets integration
class GoogleSheetsService {
    static let shared = GoogleSheetsService()
    
    // Google Sheet URL for product lookup
    private let productSheetURL = "https://docs.google.com/spreadsheets/d/1aPNjAIwY3BBKc-pyMvGYWQ1Skoncm4i7hCBwHnuyajM/edit?usp=sharing"
    
    // Sheet ID extracted from URL for product lookup
    private let productSheetID = "1aPNjAIwY3BBKc-pyMvGYWQ1Skoncm4i7hCBwHnuyajM"
    
    // Google Sheet URL for receipt data
    private let receiptSheetURL = "https://docs.google.com/spreadsheets/d/14QCCrTxF2PcyJfdL8KDCd3yEQProLm6rI6K4pp1BWq0/edit?gid=0#gid=0"
    
    // Sheet ID extracted from URL for receipt data
    private let receiptSheetID = "14QCCrTxF2PcyJfdL8KDCd3yEQProLm6rI6K4pp1BWq0"
    
    // API Key (in a real app, this would be stored securely)
    private let apiKey = "AIzaSyANOjn2MucMRlFd_mOp6ta9sNMUBvcgI70" // Replace with your actual API key
    
    private init() {}
    
    // Struct to hold product data from Google Sheets
    struct SheetProductInfo {
        let store: String
        let item: String
        let category: String
        let brand: String
        let price: String
        let quantity: String
        let pricePerUnit: String
        let link: String
        
        var numericPrice: Double {
            // Extract numeric value from price string (e.g., "$3.99" -> 3.99)
            if let priceString = price.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().nilIfEmpty {
                return Double(priceString) ?? 0.0
            }
            return 0.0
        }
    }
    
    // Struct for comparison data
    struct ComparisonResult {
        let item: String
        let storeInfo: [String: SheetProductInfo] // Store name -> Product info
    }
    
    // Struct for receipt item data
    struct ReceiptItem: Identifiable {
        let id = UUID()
        let item: String
        let price: Double
        let date: String
        let emailID: String
        
        // Additional fields for repurchase prediction
        var lastPurchaseDate: Date?
        var purchaseFrequency: Int? // Days between purchases
        var nextPurchaseDate: Date?
        var daysUntilRepurchase: Int?
        
        init(item: String, price: Double, date: String, emailID: String) {
            self.item = item
            self.price = price
            self.date = date
            self.emailID = emailID
        }
    }
    
    // Enum for possible errors
    enum GoogleSheetsError: Error {
        case networkError(Error)
        case invalidResponse
        case noDataFound
        case storeNotFound
        case itemNotFound
        case parsingError
        case writeError
    }
    
    // Function to lookup a product by name in a specific store's sheet
    func lookupProduct(name: String, store: String, completion: @escaping (Result<SheetProductInfo, GoogleSheetsError>) -> Void) {
        fetchSheet { result in
            switch result {
            case .success(let products):
                // Filter by store and item name (case-insensitive partial match)
                let matchingProducts = products.filter { 
                    $0.store.lowercased() == store.lowercased() && 
                    $0.item.lowercased().contains(name.lowercased()) 
                }
                
                if let product = matchingProducts.first {
                    completion(.success(product))
                } else {
                    completion(.failure(.itemNotFound))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Function to get all available stores from the sheet
    func getAvailableStores(completion: @escaping (Result<[String], GoogleSheetsError>) -> Void) {
        fetchSheet { result in
            switch result {
            case .success(let products):
                // Extract unique store names
                let stores = Array(Set(products.map { $0.store })).sorted()
                completion(.success(stores))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Function to compare prices of an item across all stores
    func compareItemAcrossStores(itemName: String, completion: @escaping (Result<ComparisonResult, GoogleSheetsError>) -> Void) {
        fetchSheet { result in
            switch result {
            case .success(let products):
                // Filter products by item name (case-insensitive partial match)
                let matchingProducts = products.filter { 
                    $0.item.lowercased().contains(itemName.lowercased()) 
                }
                
                if matchingProducts.isEmpty {
                    completion(.failure(.itemNotFound))
                    return
                }
                
                // Group by store
                var storeInfo: [String: SheetProductInfo] = [:]
                for product in matchingProducts {
                    storeInfo[product.store] = product
                }
                
                let comparison = ComparisonResult(
                    item: itemName,
                    storeInfo: storeInfo
                )
                
                completion(.success(comparison))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Function to get category breakdown for dashboard chart
    func getCategoryBreakdown(completion: @escaping (Result<[String: Int], GoogleSheetsError>) -> Void) {
        fetchSheet { result in
            switch result {
            case .success(let products):
                // Count items by category
                var categoryCount: [String: Int] = [:]
                
                for product in products {
                    let category = product.category.isEmpty ? "Unknown" : product.category
                    categoryCount[category, default: 0] += 1
                }
                
                completion(.success(categoryCount))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Function to write receipt data to the Google Sheet
    func writeReceiptData(items: [ReceiptItem], completion: @escaping (Result<Bool, GoogleSheetsError>) -> Void) {
        // Construct the API URL to append values to the sheet
        let baseURL = "https://sheets.googleapis.com/v4/spreadsheets/\(receiptSheetID)/values/"
        let range = "ReceiptData!A:D" // Columns A through D for item, price, date, email
        let query = ":append?valueInputOption=USER_ENTERED&insertDataOption=INSERT_ROWS&key=\(apiKey)"
        
        guard let url = URL(string: baseURL + range + query) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the data to be written
        var values: [[String]] = []
        
        for item in items {
            let row = [
                item.item,                              // Item name
                String(format: "%.2f", item.price),     // Price
                item.date,                              // Date
                item.emailID                            // Email ID
            ]
            values.append(row)
        }
        
        // Create the request body
        let body: [String: Any] = [
            "values": values
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.writeError))
            return
        }
        
        // Log what we're trying to write
        print("Writing receipt data to Google Sheet:")
        for item in items {
            print("Item: \(item.item), Price: \(item.price), Date: \(item.date), Email: \(item.emailID)")
        }
        
        // Make the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error writing to Google Sheets: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noDataFound))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Check for error in response
                    if let error = json["error"] as? [String: Any] {
                        let message = error["message"] as? String ?? "Unknown error"
                        print("Google Sheets API error: \(message)")
                        completion(.failure(.writeError))
                        return
                    }
                    
                    print("Successfully wrote data to Google Sheets")
                    completion(.success(true))
                } else {
                    completion(.failure(.parsingError))
                }
            } catch {
                print("Error parsing Google Sheets response: \(error.localizedDescription)")
                completion(.failure(.parsingError))
            }
        }.resume()
    }
    
    // Function to get purchase history for a user
    func getPurchaseHistory(email: String, completion: @escaping (Result<[ReceiptItem], GoogleSheetsError>) -> Void) {
        // In a real implementation, this would fetch data from the Google Sheet
        // For now, we'll return mock data
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Create mock purchase history
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            var items: [ReceiptItem] = []
            
            // Milk purchase history
            var milkItem = ReceiptItem(item: "Milk", price: 3.99, date: "02/15/2025", emailID: email)
            milkItem.lastPurchaseDate = dateFormatter.date(from: "02/01/2025")
            milkItem.purchaseFrequency = 14 // Every 2 weeks
            milkItem.nextPurchaseDate = dateFormatter.date(from: "03/01/2025")
            milkItem.daysUntilRepurchase = 3
            items.append(milkItem)
            
            // Bread purchase history
            var breadItem = ReceiptItem(item: "Bread", price: 2.49, date: "02/20/2025", emailID: email)
            breadItem.lastPurchaseDate = dateFormatter.date(from: "02/13/2025")
            breadItem.purchaseFrequency = 7 // Every week
            breadItem.nextPurchaseDate = dateFormatter.date(from: "02/27/2025")
            breadItem.daysUntilRepurchase = 0
            items.append(breadItem)
            
            // Eggs purchase history
            var eggsItem = ReceiptItem(item: "Eggs", price: 4.99, date: "02/10/2025", emailID: email)
            eggsItem.lastPurchaseDate = dateFormatter.date(from: "01/27/2025")
            eggsItem.purchaseFrequency = 14 // Every 2 weeks
            eggsItem.nextPurchaseDate = dateFormatter.date(from: "02/24/2025")
            eggsItem.daysUntilRepurchase = -3
            items.append(eggsItem)
            
            // Chicken purchase history
            var chickenItem = ReceiptItem(item: "Chicken Breasts", price: 9.99, date: "02/18/2025", emailID: email)
            chickenItem.lastPurchaseDate = dateFormatter.date(from: "02/04/2025")
            chickenItem.purchaseFrequency = 14 // Every 2 weeks
            chickenItem.nextPurchaseDate = dateFormatter.date(from: "03/04/2025")
            chickenItem.daysUntilRepurchase = 5
            items.append(chickenItem)
            
            // Apples purchase history
            var applesItem = ReceiptItem(item: "Apples", price: 5.99, date: "02/12/2025", emailID: email)
            applesItem.lastPurchaseDate = dateFormatter.date(from: "01/29/2025")
            applesItem.purchaseFrequency = 14 // Every 2 weeks
            applesItem.nextPurchaseDate = dateFormatter.date(from: "02/26/2025")
            applesItem.daysUntilRepurchase = -1
            items.append(applesItem)
            
            completion(.success(items))
        }
    }
    
    // Function to predict repurchase date for an item
    func predictRepurchaseDate(item: String, email: String, completion: @escaping (Result<Date?, GoogleSheetsError>) -> Void) {
        // Get purchase history
        getPurchaseHistory(email: email) { result in
            switch result {
            case .success(let items):
                // Find the item in purchase history
                if let itemData = items.first(where: { $0.item.lowercased() == item.lowercased() }) {
                    // If we have a predicted next purchase date, return it
                    if let nextPurchaseDate = itemData.nextPurchaseDate {
                        completion(.success(nextPurchaseDate))
                    } else {
                        // No prediction available
                        completion(.success(nil))
                    }
                } else {
                    // Item not found in purchase history
                    // Use Gemini API to get typical repurchase interval (simulated)
                    self.getTypicalRepurchaseInterval(item: item) { interval in
                        if let interval = interval {
                            // Calculate next purchase date based on typical interval
                            let nextDate = Calendar.current.date(byAdding: .day, value: interval, to: Date())
                            completion(.success(nextDate))
                        } else {
                            // No typical interval available
                            completion(.success(nil))
                        }
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Helper function to get typical repurchase interval for an item using Gemini API (simulated)
    private func getTypicalRepurchaseInterval(item: String, completion: @escaping (Int?) -> Void) {
        // Simulate API call to get typical repurchase interval
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Mock data for common grocery items
            let intervals: [String: Int] = [
                "milk": 7,
                "bread": 5,
                "eggs": 14,
                "chicken": 10,
                "beef": 10,
                "pork": 10,
                "fish": 7,
                "apples": 7,
                "bananas": 5,
                "oranges": 7,
                "potatoes": 14,
                "onions": 14,
                "carrots": 10,
                "lettuce": 5,
                "tomatoes": 7,
                "cheese": 14,
                "yogurt": 7,
                "butter": 21,
                "cereal": 21,
                "pasta": 30,
                "rice": 45,
                "flour": 60,
                "sugar": 60,
                "coffee": 21,
                "tea": 30,
                "juice": 7,
                "soda": 14,
                "water": 7,
                "chips": 14,
                "cookies": 14,
                "ice cream": 14,
                "chocolate": 14,
                "candy": 21,
                "soap": 60,
                "shampoo": 45,
                "toothpaste": 60,
                "toilet paper": 21,
                "paper towels": 21,
                "detergent": 45,
                "dish soap": 45
            ]
            
            // Check if we have data for this item
            for (key, interval) in intervals {
                if item.lowercased().contains(key) {
                    completion(interval)
                    return
                }
            }
            
            // Default interval for unknown items (2 weeks)
            completion(14)
        }
    }
    
    // Function to lookup a product by barcode in a specific store's sheet
    func lookupProductByBarcode(barcode: String, store: String, completion: @escaping (Result<SheetProductInfo, GoogleSheetsError>) -> Void) {
        fetchSheet { result in
            switch result {
            case .success(let products):
                // Filter by store and barcode (exact match)
                // In a real implementation, this would search for the barcode in a dedicated column
                // For this demo, we'll simulate by checking if the item name or brand contains the barcode
                let matchingProducts = products.filter { 
                    $0.store.lowercased() == store.lowercased() && 
                    ($0.item.contains(barcode) || $0.brand.contains(barcode))
                }
                
                if let product = matchingProducts.first {
                    completion(.success(product))
                } else {
                    completion(.failure(.itemNotFound))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Real API Implementation
    
    // Fetch all data from the sheet
    private func fetchSheet(completion: @escaping (Result<[SheetProductInfo], GoogleSheetsError>) -> Void) {
        // Construct the API URL to access the specific sheet
        let baseURL = "https://sheets.googleapis.com/v4/spreadsheets/\(productSheetID)/values/"
        let range = "GrocerySKUs-Testing!A:G" // Columns A through G
        let query = "?key=\(apiKey)"
        
        guard let url = URL(string: baseURL + range + query) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noDataFound))
                return
            }
            
            do {
                // Parse the JSON response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let values = json["values"] as? [[String]] {
                    
                    var products: [SheetProductInfo] = []
                    
                    // Process each row (skip header row)
                    for row in values.dropFirst() {
                        // Ensure the row has enough columns
                        guard row.count >= 7 else { continue }
                        
                        let store = row.count > 0 ? row[0] : ""
                        let item = row.count > 1 ? row[1] : ""
                        let category = row.count > 2 ? row[2] : ""
                        let brand = row.count > 3 ? row[3] : ""
                        let price = row.count > 4 ? row[4] : ""
                        let quantity = row.count > 5 ? row[5] : ""
                        let pricePerUnit = row.count > 6 ? row[6] : ""
                        let link = (row.count > 7 && row[7] is String) ? row[7] as! String : ""
                        
                        // Skip rows with empty store or item
                        if store.isEmpty || item.isEmpty { continue }
                        
                        let productInfo = SheetProductInfo(
                            store: store,
                            item: item,
                            category: category,
                            brand: brand,
                            price: price,
                            quantity: quantity,
                            pricePerUnit: pricePerUnit,
                            link: link
                        )
                        
                        products.append(productInfo)
                    }
                    
                    if products.isEmpty {
                        completion(.failure(.noDataFound))
                    } else {
                        completion(.success(products))
                    }
                } else {
                    completion(.failure(.parsingError))
                }
            } catch {
                completion(.failure(.parsingError))
            }
        }.resume()
    }
}

// Helper extension for string
extension String {
    var nilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }
} 
