import SwiftUI

struct PriceComparisonView: View {
    let productName: String
    let priceData: String
    @State private var expandedSections: Set<String> = []
    @State private var sortOption: SortOption = .priceAscending
    
    enum SortOption: String, CaseIterable, Identifiable {
        case priceAscending = "Price: Low to High"
        case priceDescending = "Price: High to Low"
        case storeName = "Store Name"
        case bestValue = "Best Value"
        
        var id: String { self.rawValue }
    }
    
    // More robust parsing logic for API response
    private var parsedSections: [PriceSection] {
        let parser = PriceDataParser()
        var sections = parser.parse(from: priceData)
        
        // Apply sorting based on selected option
        switch sortOption {
        case .priceAscending:
            sections = sections.map { section in
                var newSection = section
                newSection.items.sort { $0.price < $1.price }
                return newSection
            }
        case .priceDescending:
            sections = sections.map { section in
                var newSection = section
                newSection.items.sort { $0.price > $1.price }
                return newSection
            }
        case .storeName:
            sections = sections.map { section in
                var newSection = section
                newSection.items.sort { $0.store < $1.store }
                return newSection
            }
        case .bestValue:
            sections = sections.map { section in
                var newSection = section
                newSection.items.sort { $0.valueScore > $1.valueScore }
                return newSection
            }
        }
        
        // Find the best deals
        for i in 0..<sections.count {
            if let bestDeal = sections[i].items.min(by: { $0.price < $1.price }) {
                let bestPrice = bestDeal.price
                sections[i].items = sections[i].items.map { item in
                    var newItem = item
                    newItem.isBestDeal = item.price == bestPrice
                    return newItem
                }
            }
        }
        
        return sections
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Comparison: \(productName)")
                .font(.headline)
                .padding(.horizontal)
            
            // Sorting picker
            Picker("Sort by", selection: $sortOption) {
                ForEach(SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            
            ForEach(parsedSections, id: \.title) { section in
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        if expandedSections.contains(section.title) {
                            expandedSections.remove(section.title)
                        } else {
                            expandedSections.insert(section.title)
                        }
                    }) {
                        HStack {
                            Text(section.title)
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Image(systemName: expandedSections.contains(section.title) 
                                  ? "chevron.up" : "chevron.down")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if expandedSections.contains(section.title) {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(section.items, id: \.id) { item in
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            if item.isBestDeal {
                                                Image(systemName: "trophy.fill")
                                                    .foregroundColor(.yellow)
                                                    .font(.system(size: 12))
                                            } else {
                                                Image(systemName: "circle.fill")
                                                    .font(.system(size: 6))
                                                    .padding(.top, 6)
                                                    .opacity(0.5)
                                            }
                                            
                                            Text(item.store)
                                                .font(.subheadline)
                                                .fontWeight(item.isBestDeal ? .bold : .regular)
                                        }
                                        
                                        if !item.description.isEmpty {
                                            Text(item.description)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .padding(.leading, 15)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Price badge
                                    Text("$\(String(format: "%.2f", item.price))")
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            item.isBestDeal 
                                                ? Color.green.opacity(0.2) 
                                                : Color.gray.opacity(0.2)
                                        )
                                        .foregroundColor(
                                            item.isBestDeal 
                                                ? Color.green 
                                                : Color.primary
                                        )
                                        .cornerRadius(12)
                                        .fontWeight(item.isBestDeal ? .bold : .regular)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    item.isBestDeal ? Color.green : Color.clear, 
                                                    lineWidth: 1
                                                )
                                        )
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(
                                    item.isBestDeal 
                                        ? Color.green.opacity(0.05) 
                                        : Color.clear
                                )
                                .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            
            // Legend for indicators
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10))
                    Text("Best Deal")
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Text("$")
                        .foregroundColor(.green)
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("Price")
                        .font(.caption)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.bottom, 100) // Extra bottom padding
    }
}

// Enhanced Price Item model
struct PriceItem: Identifiable {
    let id = UUID()
    let store: String
    var price: Double
    let description: String
    let unit: String
    var valueScore: Double
    var isBestDeal: Bool = false
    
    // Calculate value score (lower price is better)
    mutating func calculateValueScore() {
        if unit.contains("oz") || unit.contains("pound") || unit.contains("lb") {
            // Extract unit amount for value calculation
            if let amount = extractAmount(from: unit) {
                valueScore = amount / price
            } else {
                valueScore = 1.0 / price
            }
        } else {
            valueScore = 1.0 / price
        }
    }
    
    private func extractAmount(from unit: String) -> Double? {
        let pattern = #"(\d+\.?\d*)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: unit, range: NSRange(unit.startIndex..., in: unit)) {
            if let range = Range(match.range(at: 1), in: unit) {
                return Double(unit[range])
            }
        }
        return nil
    }
}

// Enhanced Price Section model
struct PriceSection: Identifiable {
    let id = UUID()
    let title: String
    var items: [PriceItem]
}

// More robust parser
class PriceDataParser {
    func parse(from data: String) -> [PriceSection] {
        // Split by section markers
        let sections = data.components(separatedBy: "---")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .compactMap { parseSection($0) }
        
        return sections
    }
    
    private func parseSection(_ sectionText: String) -> PriceSection? {
        let lines = sectionText.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard lines.count > 0 else { return nil }
        
        // Extract section title
        let titleLine = lines.first { line in 
            line.contains("**") || line.contains("#") || line.contains("Category:") 
        } ?? "Pricing Information"
        
        let title = cleanTitle(titleLine)
        
        // Parse items
        var items = [PriceItem]()
        
        for line in lines.dropFirst() {
            if let item = parseItem(line) {
                items.append(item)
            }
        }
        
        // Calculate value scores for comparison
        items = items.map { item in
            var newItem = item
            newItem.calculateValueScore()
            return newItem
        }
        
        return PriceSection(title: title, items: items)
    }
    
    private func cleanTitle(_ title: String) -> String {
        return title
            .replacingOccurrences(of: "###", with: "")
            .replacingOccurrences(of: "##", with: "")
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "Category:", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseItem(_ line: String) -> PriceItem? {
        // Regular expression to extract price pattern
        let pricePattern = #"\$(\d+\.?\d*)"#
        let storePattern = #"at ([A-Za-z\s&]+):"#
        let unitPattern = #"per ([a-zA-Z0-9\s\.]+)"#
        
        // Default values
        var store = "Unknown Store"
        var price = 0.0
        var unit = ""
        
        // Extract store
        if let regex = try? NSRegularExpression(pattern: storePattern),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            if let range = Range(match.range(at: 1), in: line) {
                store = String(line[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else if line.contains(":") {
            let parts = line.split(separator: ":")
            if parts.count > 0 {
                store = String(parts[0])
                    .replacingOccurrences(of: "-", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Extract price
        if let regex = try? NSRegularExpression(pattern: pricePattern),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            if let range = Range(match.range(at: 1), in: line) {
                if let extractedPrice = Double(line[range]) {
                    price = extractedPrice
                }
            }
        }
        
        // Extract unit
        if let regex = try? NSRegularExpression(pattern: unitPattern),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            if let range = Range(match.range(at: 1), in: line) {
                unit = String(line[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Extract description (everything else)
        var description = line
            .replacingOccurrences(of: "- ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Clean up description
        if let regex = try? NSRegularExpression(pattern: storePattern) {
            description = regex.stringByReplacingMatches(
                in: description,
                range: NSRange(description.startIndex..., in: description),
                withTemplate: ""
            )
        }
        description = description
            .replacingOccurrences(of: store, with: "")
            .replacingOccurrences(of: ": ", with: "")
            .replacingOccurrences(of: "$\(price)", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return PriceItem(
            store: store,
            price: price,
            description: description,
            unit: unit,
            valueScore: 0.0
        )
    }
} 