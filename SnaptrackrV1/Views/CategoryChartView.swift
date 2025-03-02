import SwiftUI
import Charts

struct CategoryChartView: View {
    @State private var categoryData: [CategoryItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    struct CategoryItem: Identifiable {
        let id = UUID()
        let category: String
        let count: Int
        var color: Color {
            // Generate consistent colors based on category name
            let colors: [Color] = [
                .red, .blue, .green, .orange, .purple, .pink, .yellow, .teal
            ]
            // Use the hash of the category name to pick a consistent color
            let index = abs(category.hashValue) % colors.count
            return colors[index]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Item Categories Breakdown")
                .font(.headline)
                .padding(.bottom, 5)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if categoryData.isEmpty {
                Text("No category data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                // Chart
                Chart(categoryData) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(item.color)
                    .annotation(position: .overlay) {
                        Text("\(item.count)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
                .frame(height: 200)
                .padding(.vertical)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(categoryData) { item in
                        HStack {
                            Rectangle()
                                .fill(item.color)
                                .frame(width: 16, height: 16)
                            
                            Text(item.category)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        errorMessage = nil
        
        GoogleSheetsService.shared.getCategoryBreakdown { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let categories):
                    self.categoryData = categories
                        .map { CategoryItem(category: $0.key, count: $0.value) }
                        .sorted { $0.count > $1.count }
                    
                case .failure:
                    self.errorMessage = "Failed to load category data"
                }
            }
        }
    }
} 