//
//  GroceryItem.swift
//  SnaptrackrV1
//

import Foundation
import SwiftUI

// Single definition of GroceryItem to be used throughout the app
struct GroceryItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var price: Double
    var quantity: Double
    var barcode: String?
    var dateAdded: Date
    var imageData: Data?
    var weblink: String?
    var pricePerUnit: String?
    var price_per_unit: Double?
    var date: String?
    
    // For JSON decoding
    private enum CodingKeys: String, CodingKey {
        case name, price, quantity, category, price_per_unit, date, barcode, weblink
        // id is excluded since we generate it
    }
    
    // Create a formatted price string
    var priceFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
    
    // Default initializer
    init(name: String, category: String, price: Double, quantity: Double = 1.0, barcode: String? = nil, dateAdded: Date = Date(), imageData: Data? = nil, weblink: String? = nil, pricePerUnit: String? = nil) {
        self.name = name
        self.category = category
        self.price = price
        self.quantity = quantity
        self.barcode = barcode
        self.dateAdded = dateAdded
        self.imageData = imageData
        self.weblink = weblink
        self.pricePerUnit = pricePerUnit
    }
    
    // Custom decoder for API results
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        quantity = try container.decode(Double.self, forKey: .quantity)
        category = try container.decode(String.self, forKey: .category)
        price_per_unit = try container.decodeIfPresent(Double.self, forKey: .price_per_unit)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        barcode = try container.decodeIfPresent(String.self, forKey: .barcode)
        weblink = try container.decodeIfPresent(String.self, forKey: .weblink)
        
        // Set defaults for properties not in JSON
        dateAdded = Date()
        imageData = nil
        id = UUID()
    }
} 