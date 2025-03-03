import SwiftUI
import Charts

// Helper struct for chart data
struct CategoryCount: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
}

// Helper struct for price drop data
struct PriceDrop: Identifiable {
    let id = UUID()
    let itemName: String
    let oldPrice: Double
    let newPrice: Double
    let store: String
    let percentDrop: Double
    
    var savings: Double {
        oldPrice - newPrice
    }
}

// Smart List Item Component
struct SmartListItemView: View {
    let item: GroceryItem
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var showConfetti = false
    
    // Simplify the statusColor property
    var statusColor: Color {
        // Since we can't check expiry, use a default color
        return Color.green
    }
    
    var body: some View {
        ZStack {
            // Background for swipe actions
            HStack(spacing: 0) {
                // Left swipe action - Move to Shopping List
                Button(action: {
                    // Add to shopping list logic
                    withAnimation(.spring()) {
                        offset = 0
                        isSwiped = false
                    }
                }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                        Text("Add to List")
                    }
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                }
                .frame(width: 120)
                
                Spacer()
                
                // Right swipe action - Compare Prices
                Button(action: {
                    // Compare prices logic
                    withAnimation(.spring()) {
                        offset = 0
                        isSwiped = false
                    }
                }) {
                    HStack {
                        Text("Compare")
                        Image(systemName: "tag")
                    }
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                }
                .frame(width: 120)
            }
            
            // Foreground card
            VStack {
                HStack(alignment: .top, spacing: 12) {
                    // Status indicator
                    Circle()
                        .fill(statusColor)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text(item.category)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            Text("Added \(item.dateAdded.formatted(date: .abbreviated, time: .omitted))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(statusColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(statusColor.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(item.priceFormatted)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(item.quantity)×")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 68/255, green: 36/255, blue: 164/255).opacity(0.7),
                                    Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.5),
                                            Color.white.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .overlay(
                    showConfetti ? ConfettiView() : nil
                )
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            // Limit left swipe
                            self.offset = max(gesture.translation.width, -120)
                        } else if gesture.translation.width > 0 {
                            // Limit right swipe
                            self.offset = min(gesture.translation.width, 120)
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring()) {
                            if gesture.translation.width < -50 {
                                // Swiped left enough to reveal right action
                                self.offset = -120
                                self.isSwiped = true
                            } else if gesture.translation.width > 50 {
                                // Swiped right enough to reveal left action
                                self.offset = 120
                                self.isSwiped = true
                            } else {
                                // Not swiped enough, return to center
                                self.offset = 0
                                self.isSwiped = false
                            }
                        }
                    }
            )
        }
        .onAppear {
            // Since we removed isOverdue property, we'll show confetti based on a different condition
            if item.quantity > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showConfetti = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showConfetti = false
                        }
                    }
                }
            }
        }
    }
}

// Confetti Animation View
struct ConfettiView: View {
    @State private var particles = [Particle]()
    
    struct Particle: Identifiable {
        let id = UUID()
        let position: CGPoint
        let color: Color
        let rotation: Double
        let size: CGFloat
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Rectangle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size * 2)
                    .position(x: particle.position.x, y: particle.position.y)
                    .rotationEffect(.degrees(particle.rotation))
            }
        }
        .onAppear {
            generateParticles()
        }
    }
    
    private func generateParticles() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
        
        for _ in 0..<20 {
            let randomX = CGFloat.random(in: 0...300)
            let randomY = CGFloat.random(in: 0...100)
            let randomRotation = Double.random(in: 0...360)
            let randomSize = CGFloat.random(in: 2...5)
            let randomColor = colors.randomElement() ?? .red
            
            let particle = Particle(
                position: CGPoint(x: randomX, y: randomY),
                color: randomColor,
                rotation: randomRotation,
                size: randomSize
            )
            
            particles.append(particle)
        }
    }
}

// Recent Price Drops Component
struct RecentPriceDropsView: View {
    let priceDrops: [PriceDrop]
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            if priceDrops.isEmpty {
                Text("No recent price drops")
                    .italic()
                    .foregroundColor(.white.opacity(0.7))
            } else {
                ForEach(priceDrops) { drop in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(drop.itemName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text(drop.store)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Text(drop.oldPrice.formatted(.currency(code: "USD")))
                                    .strikethrough()
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("→")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(drop.newPrice.formatted(.currency(code: "USD")))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("↓ \(Int(drop.percentDrop))%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 68/255, green: 36/255, blue: 164/255).opacity(0.6),
                                        Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.5),
                                                Color.white.opacity(0.1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(priceDrops.firstIndex(where: { $0.id == drop.id }) ?? 0) * 0.1),
                        value: isAnimating
                    )
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

// Smart List Component
struct SmartListView: View {
    let items: [GroceryItem]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(items.prefix(3)) { item in
                HStack {
                    // Item info
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.category)
                            .font(.subheadline)
                            .opacity(0.7)
                    }
                    
                    Spacer()
                    
                    // Price and quantity
                    VStack(alignment: .trailing) {
                        Text("$\(item.price, specifier: "%.2f")")
                            .font(.headline)
                        Text("\(item.quantity)×")
                            .font(.subheadline)
                            .opacity(0.7)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
            
            if items.isEmpty {
                Text("No items in your smart list")
                    .font(.headline)
                    .opacity(0.7)
                    .padding()
            }
        }
    }
}

// Main Dashboard View (formerly InventoryView)
struct InventoryView: View {
    @StateObject private var inventoryManager = InventoryManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var isAnimating = false
    
    // Sample price drops data (would come from API/database in real app)
    let priceDrops: [PriceDrop] = [
        PriceDrop(itemName: "Organic Milk", oldPrice: 4.99, newPrice: 3.99, store: "Whole Foods", percentDrop: 20),
        PriceDrop(itemName: "Chicken Breast", oldPrice: 8.99, newPrice: 6.49, store: "Trader Joe's", percentDrop: 28),
        PriceDrop(itemName: "Avocados (4pk)", oldPrice: 5.99, newPrice: 4.49, store: "Costco", percentDrop: 25)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title and Search
                Text("Dashboard")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                searchBar
                
                // Dashboard cards
                dashboardCards
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
            
            TextField("Search items...", text: $searchText)
                .foregroundColor(.white)
                .accentColor(.white)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Material.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    private var dashboardCards: some View {
        VStack(spacing: 20) {
            // Smart List card
            DashboardCard(title: "Smart List", icon: "list.bullet.clipboard.fill") {
                SmartListView(items: inventoryManager.groceryItems)
            }
            .offset(y: isAnimating ? 0 : 50)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: isAnimating)
            
            // Recent Price Drops card
            DashboardCard(title: "Recent Price Drops", icon: "arrow.down.circle.fill") {
                RecentPriceDropsView(priceDrops: priceDrops)
            }
            .offset(y: isAnimating ? 0 : 50)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: isAnimating)
            
            // Inventory overview card
            DashboardCard(title: "Inventory Overview", icon: "chart.pie.fill") {
                VStack(spacing: 16) {
                    HStack {
                        Chart {
                            ForEach(inventoryCategoryCounts) { item in
                                SectorMark(
                                    angle: .value("Count", item.count),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(by: .value("Category", item.category))
                                .cornerRadius(5)
                            }
                        }
                        .frame(height: 120)
                        .chartLegend(.hidden)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Items: \(totalItems)")
                                .font(.headline)
                            Text("Categories: \(activeCategories)")
                                .font(.subheadline)
                            Text("Est. Value: \(totalValue.formatted(.currency(code: "USD")))")
                                .font(.subheadline)
                        }
                    }
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button(action: { handleCategorySelection("All") }) {
                                Text("All Items")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == nil ? Color.white : Color.white.opacity(0.2))
                                    .foregroundColor(selectedCategory == nil ? Color.purple : Color.white)
                                    .cornerRadius(20)
                            }
                            
                            ForEach(activeCategoryList, id: \.self) { category in
                                Button(action: { handleCategorySelection(category) }) {
                                    let isSelected = selectedCategory == category
                                    
                                    Text(category)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? Color.white : Color.white.opacity(0.2))
                                        .foregroundColor(isSelected ? Color.purple : Color.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                }
            }
            .offset(y: isAnimating ? 0 : 50)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3), value: isAnimating)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    // Helper function to handle category selection
    private func handleCategorySelection(_ category: String) {
        if category == "All" {
            selectedCategory = nil
        } else if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
    
    // Helper computed properties
    private var filteredItems: [GroceryItem] {
        var items = inventoryManager.groceryItems
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            items = items.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        return items
    }
    
    private var inventoryCategoryCounts: [CategoryCount] {
        let categories = Dictionary(grouping: inventoryManager.groceryItems) { $0.category }
            .mapValues { $0.count }
        return categories.map { CategoryCount(category: $0.key, count: $0.value) }
    }
    
    private var totalValue: Double {
        inventoryManager.groceryItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    private var totalItems: Int {
        Int(inventoryManager.groceryItems.reduce(0) { $0 + $1.quantity })
    }
    
    private var activeCategories: Int {
        Set(inventoryManager.groceryItems.map { $0.category }).count
    }
    
    private var activeCategoryList: [String] {
        Array(Set(inventoryManager.groceryItems.map { $0.category })).sorted()
    }
}

// Enhanced Dashboard card component with glassmorphism
struct DashboardCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }
            .foregroundColor(.white)
            
            content
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Material.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
    }
}
