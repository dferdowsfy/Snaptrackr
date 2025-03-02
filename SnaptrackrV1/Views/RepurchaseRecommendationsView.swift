import SwiftUI

struct RepurchaseRecommendationsView: View {
    let itemName: String
    @State private var recommendation: RepurchaseRecommendation?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Repurchase Recommendation")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if isLoading {
                    loadingView
                } else if let recommendation = recommendation {
                    // Product card
                    VStack(alignment: .leading, spacing: 16) {
                        productHeaderView(recommendation: recommendation)
                        Divider()
                        repurchaseDateView(recommendation: recommendation)
                        Divider()
                        reasoningView(recommendation: recommendation)
                    }
                } else {
                    errorView
                }
            }
            .padding()
        }
        .onAppear {
            generateRecommendation()
        }
    }
    
    // MARK: - Content Views
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding(.vertical, 30)
            
            Text("Analyzing your shopping patterns...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
    private func productHeaderView(recommendation: RepurchaseRecommendation) -> some View {
        HStack {
            Image(systemName: getCategoryIcon(for: recommendation.itemName))
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text("Product")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(recommendation.itemName)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func repurchaseDateView(recommendation: RepurchaseRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended Repurchase")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.green)
                
                Text(recommendation.repurchaseDate)
                    .font(.headline)
            }
        }
    }
    
    private func reasoningView(recommendation: RepurchaseRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reasoning")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(recommendation.reasoning)
                .font(.body)
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
                .padding()
            
            Text("Unable to generate recommendation")
                .font(.headline)
            
            Text("We don't have enough data about this product yet. Try scanning more receipts or adding purchase history.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
    // MARK: - Helper Functions
    
    private func generateRecommendation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.recommendation = RepurchaseRecommendationEngine.generateRecommendation(for: itemName)
            self.isLoading = false
        }
    }
    
    private func getCategoryIcon(for product: String) -> String {
        let product = product.lowercased()
        
        if product.contains("milk") || product.contains("cheese") || product.contains("yogurt") {
            return "cup.and.saucer.fill"
        } else if product.contains("bread") || product.contains("bagel") || product.contains("muffin") {
            return "birthday.cake.fill"
        } else if product.contains("apple") || product.contains("banana") || product.contains("fruit") {
            return "leaf.fill"
        } else if product.contains("chicken") || product.contains("beef") || product.contains("meat") {
            return "fork.knife"
        } else if product.contains("detergent") || product.contains("soap") || product.contains("cleaner") {
            return "bubbles.and.sparkles.fill"
        } else if product.contains("toilet") || product.contains("paper") || product.contains("tissue") {
            return "scroll.fill"
        } else {
            return "cart.fill"
        }
    }
} 