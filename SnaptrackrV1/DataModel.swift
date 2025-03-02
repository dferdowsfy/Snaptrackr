import SwiftUI
import Foundation
import Combine

// Singleton to manage grocery inventory
class InventoryManager: ObservableObject {
    static let shared = InventoryManager()
    
    @Published var groceryItems: [GroceryItem] = []
    @Published var shoppingList: [GroceryItem] = []
    @Published var recentScans: [GroceryItem] = []
    
    // Categories for organization
    let categories = ["Produce", "Dairy", "Meat", "Bakery", "Pantry", "Frozen", "Beverages", "Household", "Other"]
    
    private init() {
        // Load sample data for testing
        loadSampleData()
    }
    
    // Add an item to inventory
    func addItem(_ item: GroceryItem) {
        // Check if item already exists
        if let index = groceryItems.firstIndex(where: { $0.name.lowercased() == item.name.lowercased() }) {
            // Update existing item
            var updatedItem = groceryItems[index]
            updatedItem.quantity += item.quantity
            groceryItems[index] = updatedItem
        } else {
            // Add new item
            groceryItems.append(item)
        }
        
        // Add to recent scans
        recentScans.insert(item, at: 0)
        if recentScans.count > 5 {
            recentScans.removeLast()
        }
    }
    
    // Process receipt data (from Gemini API)
    func processReceiptData(_ jsonString: String, storeName: String = "Unknown Store") {
        print("Processing receipt data: \(jsonString)")
        
        // Clean up the string to ensure it's valid JSON
        var cleanJson = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If it starts with "```json" (common with AI responses), clean that up
        if cleanJson.hasPrefix("```json") {
            cleanJson = cleanJson.replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Remove any markdown code block markers
        cleanJson = cleanJson.replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanJson.data(using: .utf8) else {
            print("Failed to convert string to data")
            return
        }
        
        // Format the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let currentDateString = dateFormatter.string(from: Date())
        
        // Create receipt title with store name and date
        let receiptTitle = "\(storeName), \(currentDateString)"
        
        do {
            // Try to parse as JSON array of items
            if let receiptItems = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
                print("Successfully parsed \(receiptItems.count) items")
                
                var receiptDate = currentDateString
                
                // Check if any item has a date field
                for itemData in receiptItems {
                    if let date = itemData["date"] as? String, !date.isEmpty {
                        receiptDate = date
                        break
                    }
                }
                
                // Update receipt title with the found date
                let finalReceiptTitle = "\(storeName), \(receiptDate)"
                print("Receipt title: \(finalReceiptTitle)")
                
                // Prepare items for Google Sheets
                var googleSheetsItems: [GoogleSheetsService.ReceiptItem] = []
                
                for itemData in receiptItems {
                    // Extract item details
                    guard let name = itemData["name"] as? String else {
                        print("Missing name in item: \(itemData)")
                        continue
                    }
                    
                    let price: Double
                    if let priceNum = itemData["price"] as? Double {
                        price = priceNum
                    } else if let priceNum = itemData["price"] as? Int {
                        price = Double(priceNum)
                    } else if let priceStr = itemData["price"] as? String,
                              let priceNum = Double(priceStr) {
                        price = priceNum
                    } else {
                        print("Invalid price format for \(name)")
                        price = 0.0
                    }
                    
                    let quantity: Int
                    if let qtyNum = itemData["quantity"] as? Int {
                        quantity = qtyNum
                    } else if let qtyNum = itemData["quantity"] as? Double {
                        quantity = Int(qtyNum)
                    } else if let qtyStr = itemData["quantity"] as? String,
                              let qtyNum = Int(qtyStr) {
                        quantity = qtyNum
                    } else {
                        print("Invalid quantity format for \(name), defaulting to 1")
                        quantity = 1
                    }
                    
                    let category = (itemData["category"] as? String) ?? "Other"
                    
                    print("Adding item: \(name), price: \(price), qty: \(quantity), category: \(category)")
                    
                    // Create and add the item to local inventory
                    let newItem = GroceryItem(
                        name: name,
                        category: category,
                        price: price,
                        quantity: Double(quantity),
                        barcode: nil,
                        dateAdded: Date(),
                        imageData: nil,
                        weblink: nil,
                        pricePerUnit: nil
                    )
                    
                    addItem(newItem)
                    
                    // Add to Google Sheets items
                    let sheetsItem = GoogleSheetsService.ReceiptItem(
                        item: name,
                        price: price,
                        date: receiptDate,
                        emailID: "user@example.com" // Replace with actual user email when available
                    )
                    googleSheetsItems.append(sheetsItem)
                }
                
                // Send data to Google Sheets
                if !googleSheetsItems.isEmpty {
                    GoogleSheetsService.shared.writeReceiptData(items: googleSheetsItems) { result in
                        switch result {
                        case .success:
                            print("Successfully wrote \(googleSheetsItems.count) items to Google Sheets")
                        case .failure(let error):
                            print("Failed to write to Google Sheets: \(error)")
                        }
                    }
                }
                
            } else {
                // Fall back to text processing if JSON parsing failed
                print("JSON parsing failed, trying text processing")
                processTextReceiptData(jsonString)
            }
        } catch {
            print("Error parsing receipt data: \(error.localizedDescription)")
            // Fall back to text processing
            processTextReceiptData(jsonString)
        }
    }
    
    // Helper method to process receipt as plain text
    private func processTextReceiptData(_ text: String) {
        print("Processing receipt as text")
        let lines = text.components(separatedBy: .newlines)
        
        // Format the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let currentDateString = dateFormatter.string(from: Date())
        
        // Prepare items for Google Sheets
        var googleSheetsItems: [GoogleSheetsService.ReceiptItem] = []
        
        for line in lines {
            // Skip empty lines or lines that don't contain price patterns
            if line.isEmpty || !line.contains("$") {
                continue
            }
            
            // Try to extract price and item name
            if let priceRange = line.range(of: "\\$\\d+\\.\\d+", options: .regularExpression) {
                let priceString = line[priceRange].dropFirst() // Remove the $ sign
                if let price = Double(priceString) {
                    // Extract item name (assume it's everything before the price)
                    let parts = line.components(separatedBy: "$")
                    if parts.count >= 1 {
                        let itemNamePart = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !itemNamePart.isEmpty && itemNamePart.count > 2 {
                            // Add the item to local inventory
                            let newItem = GroceryItem(
                                name: itemNamePart,
                                category: "Other", // Default category
                                price: price,
                                quantity: 1,
                                barcode: nil,
                                dateAdded: Date(),
                                imageData: nil,
                                weblink: nil,
                                pricePerUnit: nil
                            )
                            
                            print("Adding text-parsed item: \(itemNamePart) at $\(price)")
                            addItem(newItem)
                            
                            // Add to Google Sheets items
                            let sheetsItem = GoogleSheetsService.ReceiptItem(
                                item: itemNamePart,
                                price: price,
                                date: currentDateString,
                                emailID: "user@example.com" // Replace with actual user email when available
                            )
                            googleSheetsItems.append(sheetsItem)
                        }
                    }
                }
            }
        }
        
        // Send data to Google Sheets
        if !googleSheetsItems.isEmpty {
            GoogleSheetsService.shared.writeReceiptData(items: googleSheetsItems) { result in
                switch result {
                case .success:
                    print("Successfully wrote \(googleSheetsItems.count) text-parsed items to Google Sheets")
                case .failure(let error):
                    print("Failed to write text-parsed items to Google Sheets: \(error)")
                }
            }
        }
    }
    
    // Process barcode product data (from Perplexity API)
    func processBarcodeData(_ productInfo: String, barcode: String) {
        // Extract product name
        let lines = productInfo.components(separatedBy: .newlines)
        var productName = "Unknown Product"
        var category = "Other"
        var price = 0.0
        
        // Try to extract name from first line or "Name:" line
        if let firstLine = lines.first, !firstLine.isEmpty {
            productName = firstLine
        }
        
        for line in lines {
            if line.lowercased().contains("name:") {
                productName = line.replacingOccurrences(of: "Name:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if line.lowercased().contains("category:") {
                category = line.replacingOccurrences(of: "Category:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if line.lowercased().contains("price:") || line.lowercased().contains("cost:") {
                let priceString = line.replacingOccurrences(of: "Price:", with: "")
                                     .replacingOccurrences(of: "Cost:", with: "")
                                     .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Extract numeric price from string like "$5.99" or "5.99"
                if let match = priceString.range(of: "\\d+\\.\\d+", options: .regularExpression) {
                    if let extractedPrice = Double(priceString[match]) {
                        price = extractedPrice
                    }
                }
            }
        }
        
        // Create and add item
        let newItem = GroceryItem(
            name: productName,
            category: category,
            price: price,
            quantity: 1,
            barcode: barcode,
            dateAdded: Date(),
            imageData: nil,
            weblink: nil,
            pricePerUnit: nil
        )
        
        addItem(newItem)
    }
    
    // Load sample data for testing
    private func loadSampleData() {
        let sampleItems = [
            GroceryItem(
                name: "Milk", 
                category: "Dairy", 
                price: 3.99, 
                quantity: 2, 
                barcode: "123456789", 
                dateAdded: Date(), 
                imageData: nil,
                weblink: "https://www.walmart.com/ip/Great-Value-Whole-Vitamin-D-Milk-Gallon-128-fl-oz/10450114",
                pricePerUnit: "$0.031 per fl oz"
            ),
            GroceryItem(
                name: "Bread", 
                category: "Bakery", 
                price: 2.49, 
                quantity: 1, 
                barcode: "987654321", 
                dateAdded: Date(), 
                imageData: nil,
                weblink: "https://www.walmart.com/ip/Wonder-Bread-Classic-White-Bread-20-oz-Loaf/37858875",
                pricePerUnit: "$0.125 per oz"
            ),
            GroceryItem(
                name: "Eggs", 
                category: "Dairy", 
                price: 4.99, 
                quantity: 1, 
                barcode: "456789123", 
                dateAdded: Date(), 
                imageData: nil,
                weblink: "https://www.walmart.com/ip/Great-Value-Large-White-Eggs-18-Count/172844767",
                pricePerUnit: "$0.277 per egg"
            ),
            GroceryItem(
                name: "Chicken Breasts", 
                category: "Meat", 
                price: 9.99, 
                quantity: 3, 
                barcode: "789123456", 
                dateAdded: Date(), 
                imageData: nil,
                weblink: "https://www.walmart.com/ip/All-Natural-Boneless-Skinless-Chicken-Breasts-2-5-3-5-lb/27648302",
                pricePerUnit: "$3.33 per lb"
            )
        ]
        
        groceryItems = sampleItems
        recentScans = Array(sampleItems.prefix(3))
    }
    
    // Add this method to the InventoryManager class
    func updateItem(_ item: GroceryItem) {
        if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems[index] = item
        }
    }
} 
