//
//  Item.swift
//  SnaptrackrV1
//
//  Created by Ferdows, Darius on 2/26/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var price: Double
    var quantity: Double
    var category: String?
    var title: String?
    var notes: String?
    
    init(timestamp: Date = Date(), 
         price: Double = 0.0, 
         quantity: Double = 1.0, 
         category: String? = nil,
         title: String? = nil,
         notes: String? = nil) {
        self.timestamp = timestamp
        self.price = price
        self.quantity = quantity
        self.category = category
        self.title = title
        self.notes = notes
    }
}
