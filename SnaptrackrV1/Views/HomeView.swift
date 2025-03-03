import SwiftUI

struct HomeView: View {
    @StateObject private var authManager = AuthManager.shared
    @ObservedObject private var inventoryManager = InventoryManager.shared
    @State private var expandedSections: Set<String> = []
    @State private var priceAlerts: [PriceAlert] = []
    @State private var isLoadingAlerts = false
    
    // Define PriceAlert struct
    struct PriceAlert: Identifiable {
        let id = UUID()
        let item: String
        let currentPrice: Double
        let lowestPrice: Double
        let store: String
        
        var savings: Int {
            guard currentPrice > 0 else { return 0 }
            return Int(((currentPrice - lowestPrice) / currentPrice) * 100)
        }
        
        var savingsFormatted: String {
            return "\(savings)%"
        }
        
        var currentPriceFormatted: String {
            return "$\(String(format: "%.2f", currentPrice))"
        }
        
        var lowestPriceFormatted: String {
            return "$\(String(format: "%.2f", lowestPrice))"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back,")
                        .font(.title2)
                        .foregroundColor(.black.opacity(0.8))
                    
                    Text(authManager.currentUser?.name ?? "User")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Expandable cards
                inventorySection
                expiringSoonSection
                
                // Recent activity section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Activity")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                    
                    // Activity list
                    VStack(spacing: 12) {
                        if inventoryManager.recentScans.isEmpty {
                            Text("No recent activity")
                                .foregroundColor(.white.opacity(0.7))
                                .padding()
                        } else {
                            ForEach(inventoryManager.recentScans.prefix(4)) { item in
                                activityItem(
                                    title: "Added \(item.name)",
                                    subtitle: "\(item.category) • \(item.priceFormatted)",
                                    time: formatDate(item.dateAdded),
                                    icon: "plus.circle.fill",
                                    color: .green
                                )
                            }
                            
                            // Add expiring items if any
                            ForEach(getExpiringSoonItems().prefix(2)) { item in
                                activityItem(
                                    title: "\(item.name) Expiring",
                                    subtitle: "Expires soon",
                                    time: "Soon",
                                    icon: "clock.fill",
                                    color: .yellow
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
                .padding(.top, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                )
                
                // Price alerts section
                priceAlertsSection
                
                // Spacer for bottom padding
                Spacer(minLength: 80)
            }
        }
        .background(Color.clear)
        .onAppear {
            // Check for price alerts when view appears
            checkPriceAlerts()
        }
    }
    
    // MARK: - Activity Item
    private func activityItem(title: String, subtitle: String, time: String, icon: String, color: Color) -> some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.7))
            }
            
            Spacer()
            
            // Time
            Text(time)
                .font(.system(size: 12))
                .foregroundColor(.black.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Expandable Card
    struct ExpandableCard<Content: View>: View {
        let title: String
        let count: String
        let icon: String
        let color: Color
        let isExpanded: Bool
        let onToggle: () -> Void
        let content: Content
        
        init(
            title: String,
            count: String,
            icon: String,
            color: Color,
            isExpanded: Bool,
            onToggle: @escaping () -> Void,
            @ViewBuilder content: () -> Content
        ) {
            self.title = title
            self.count = count
            self.icon = icon
            self.color = color
            self.isExpanded = isExpanded
            self.onToggle = onToggle
            self.content = content()
        }
        
        var body: some View {
            VStack(spacing: 0) {
                // Header (always visible)
                Button(action: onToggle) {
                    HStack(alignment: .top, spacing: 12) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: icon)
                                .font(.system(size: 18))
                                .foregroundColor(color)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.8))
                            
                            Text(count)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        // Expand/collapse icon
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.black.opacity(0.7))
                            .padding(.top, 8)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: isExpanded ? 15 : 20)
                            .fill(color.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: isExpanded ? 15 : 20)
                                    .stroke(color.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Expandable content
                if isExpanded {
                    content
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(color.opacity(0.1))
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Inventory Section
    private var inventorySection: some View {
        ExpandableCard(
            title: "Inventory",
            count: "\(inventoryManager.groceryItems.count)",
            icon: "cube.box.fill",
            color: Color(red: 84/255, green: 212/255, blue: 228/255),
            isExpanded: expandedSections.contains("Inventory"),
            onToggle: {
                toggleSection("Inventory")
            }
        ) {
            // Content when expanded
            VStack(spacing: 10) {
                ForEach(inventoryManager.groceryItems.prefix(5)) { item in
                    HStack {
                        Text(item.name)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(item.priceFormatted)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                if inventoryManager.groceryItems.count > 5 {
                    Button(action: {
                        // Navigate to full inventory
                    }) {
                        Text("View all \(inventoryManager.groceryItems.count) items")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.top, 5)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Expiring Soon Section
    private var expiringSoonSection: some View {
        ExpandableCard(
            title: "Expiring Soon",
            count: "\(getExpiringSoonCount())",
            icon: "exclamationmark.circle.fill",
            color: .orange,
            isExpanded: expandedSections.contains("ExpiringSoon"),
            onToggle: {
                toggleSection("ExpiringSoon")
            }
        ) {
            // Content when expanded
            VStack(spacing: 10) {
                ForEach(getExpiringSoonItems()) { item in
                    HStack {
                        Text(item.name)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("Expires soon")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Price Alerts Section
    private var priceAlertsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Price Alerts")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            if isLoadingAlerts {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if priceAlerts.isEmpty {
                Text("No price alerts available")
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(priceAlerts) { alert in
                            priceAlertCard(
                                item: alert.item,
                                currentPrice: alert.currentPriceFormatted,
                                lowestPrice: alert.lowestPriceFormatted,
                                store: alert.store,
                                savings: alert.savingsFormatted
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.top, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
        )
    }
    
    // MARK: - Price Alert Card
    private func priceAlertCard(item: String, currentPrice: String, lowestPrice: String, store: String, savings: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item)
                .font(.headline)
                .foregroundColor(.black)
                .lineLimit(1)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Price")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text(currentPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(store)")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text(lowestPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                Text("Save \(savings)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(4)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Action to view details
                }) {
                    Text("View Deal")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(4)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .frame(width: 220)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Functions
    private func toggleSection(_ section: String) {
        withAnimation(.spring()) {
            if expandedSections.contains(section) {
                expandedSections.remove(section)
            } else {
                expandedSections.insert(section)
            }
        }
    }
    
    private func getExpiringSoonCount() -> Int {
        // In a real app, you would check expiration dates
        // For now, let's assume 20% of items are expiring soon
        return max(1, inventoryManager.groceryItems.count / 5)
    }
    
    private func getExpiringSoonItems() -> [GroceryItem] {
        // In a real app, you would filter by expiration date
        // For now, just return a subset of items
        return Array(inventoryManager.groceryItems.prefix(2))
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today, \(formatTime(date))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday, \(formatTime(date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func checkPriceAlerts() {
        // Check if we need to refresh price alerts (once a week)
        let lastCheck = UserDefaults.standard.object(forKey: "lastPriceAlertCheck") as? Date
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())
        
        if lastCheck == nil || lastCheck! < oneWeekAgo! {
            isLoadingAlerts = true
            
            // Get items to check prices for
            let itemsToCheck = inventoryManager.groceryItems.prefix(5)
            
            // Create a dispatch group to wait for all API calls
            let group = DispatchGroup()
            var newAlerts: [PriceAlert] = []
            
            for item in itemsToCheck {
                group.enter()
                
                // Use Perplexity API to check prices
                APIService.shared.queryPerplexityForPriceComparison(item.name) { result in
                    defer { group.leave() }
                    
                    switch result {
                    case .success(let data):
                        // Parse the response to find price alerts
                        if let alert = self.parsePriceAlert(item: item, data: data) {
                            newAlerts.append(alert)
                        }
                    case .failure(let error):
                        print("Error checking price: \(error.localizedDescription)")
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.priceAlerts = newAlerts
                self.isLoadingAlerts = false
                
                // Save the current date as the last check time
                UserDefaults.standard.set(Date(), forKey: "lastPriceAlertCheck")
            }
        } else {
            // Load cached alerts
            // In a real app, you would store and retrieve these from UserDefaults or a database
        }
    }
    
    private func parsePriceAlert(item: GroceryItem, data: String) -> PriceAlert? {
        // This is a placeholder - in a real app, you would parse the API response
        // For now, let's create a random alert for demonstration
        let stores = ["Walmart", "Trader Joe's", "Costco", "Whole Foods", "Aldi"]
        let randomStore = stores.randomElement() ?? "Walmart"
        let currentPrice = item.price
        let lowestPrice = currentPrice * Double.random(in: 0.7...0.9) // 10-30% lower
        
        return PriceAlert(
            item: item.name,
            currentPrice: currentPrice,
            lowestPrice: lowestPrice,
            store: randomStore
        )
    }
}

// Add this extension to APIService to support price comparison
extension APIService {
    func queryPerplexityForPriceComparison(_ itemName: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Construct the prompt for Perplexity
        let prompt = """
        I'm looking for the current price of \(itemName) at different stores like Walmart, Target, Costco, Whole Foods, and Trader Joe's.
        Please provide the current prices at these stores in a simple format.
        """
        
        // Create the API request
        let apiKey = "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" // Use your actual API key
        let url = URL(string: "https://api.perplexity.ai/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "llama-3-sonar-small-32k-online",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 1024
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Make the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
                } else {
                    completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

#Preview {
    HomeView()
}
