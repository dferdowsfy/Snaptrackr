import SwiftUI
import Charts

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var expandedSections: Set<String> = ["Inventory Summary"]
    
    private let sections = [
        "Inventory Summary",
        "Expiring Soon",
        "Price Alerts"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Total Items",
                            value: "\(viewModel.items.count)",
                            icon: "cube.box.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Expiring Soon",
                            value: "\(viewModel.expiringSoonItems.count)",
                            icon: "exclamationmark.triangle.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Overdue Items",
                            value: "\(viewModel.overdueItems.count)",
                            icon: "xmark.circle.fill",
                            color: .red
                        )
                        
                        StatCard(
                            title: "Categories",
                            value: "\(viewModel.uniqueCategories.count)",
                            icon: "tag.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Expandable Sections
                    ForEach(sections, id: \.self) { section in
                        ExpandableCard(
                            title: section,
                            isExpanded: .init(
                                get: { expandedSections.contains(section) },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedSections.insert(section)
                                    } else {
                                        expandedSections.remove(section)
                                    }
                                }
                            ),
                            onToggle: {
                                withAnimation(.spring()) {
                                    if expandedSections.contains(section) {
                                        expandedSections.remove(section)
                                    } else {
                                        expandedSections.insert(section)
                                    }
                                }
                            }
                        ) {
                            switch section {
                            case "Inventory Summary":
                                inventorySummaryContent
                            case "Expiring Soon":
                                expiringSoonContent
                            case "Price Alerts":
                                priceAlertsContent
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.2, blue: 0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Inventory")
        }
        .onAppear {
            if viewModel.items.isEmpty {
                loadSampleData()
            }
        }
    }
    
    private var inventorySummaryContent: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.uniqueCategories, id: \.self) { category in
                let items = viewModel.items.filter { $0.item.contains(category) }
                HStack {
                    Text(category)
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Text("\(items.count) items")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var expiringSoonContent: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.expiringSoonItems) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.item)
                            .font(.system(size: 16, weight: .medium))
                        Text(item.date)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(String(format: "$%.2f", item.price))
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var priceAlertsContent: some View {
        VStack(spacing: 16) {
            Text("No price alerts")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    private func loadSampleData() {
        let userEmail = "user@example.com" // Replace with actual user email
        let sampleItems = [
            GoogleSheetsService.ReceiptItem(item: "Milk", price: 3.99, date: "2024-03-15", emailID: userEmail),
            GoogleSheetsService.ReceiptItem(item: "Electronics Charger", price: 19.99, date: "2024-03-10", emailID: userEmail),
            GoogleSheetsService.ReceiptItem(item: "Clothing T-Shirt", price: 24.99, date: "2024-03-05", emailID: userEmail),
            GoogleSheetsService.ReceiptItem(item: "Entertainment Movie", price: 14.99, date: "2024-03-01", emailID: userEmail),
            GoogleSheetsService.ReceiptItem(item: "Food Pizza", price: 12.99, date: "2024-02-28", emailID: userEmail)
        ]
        
        viewModel.items = sampleItems
        viewModel.errorMessage = nil
        viewModel.isLoading = false
    }
}

// ViewModel
class ShoppingListViewModel: ObservableObject {
    @Published var items: [GoogleSheetsService.ReceiptItem] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    var expiringSoonItems: [GoogleSheetsService.ReceiptItem] {
        items.filter { item in
            guard let date = DateFormatter.iso8601.date(from: item.date) else { return false }
            let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
            return daysUntilExpiry >= 0 && daysUntilExpiry <= 7
        }
    }
    
    var overdueItems: [GoogleSheetsService.ReceiptItem] {
        items.filter { item in
            guard let date = DateFormatter.iso8601.date(from: item.date) else { return false }
            return date < Date()
        }
    }
    
    var uniqueCategories: [String] {
        Array(Set(items.compactMap { item in
            if item.item.contains("Electronics") { return "Electronics" }
            if item.item.contains("Clothing") { return "Clothing" }
            if item.item.contains("Entertainment") { return "Entertainment" }
            if item.item.contains("Food") { return "Food" }
            return "Other"
        })).sorted()
    }
}

// Date Formatter Extension
extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
} 