import Foundation

// Renamed file and added 'Model' suffix to avoid conflicts
struct RepurchaseRecommendationModel {
    let itemName: String
    let recommendedRepurchaseDate: Date
    let reasoning: String
}

// Renamed engine to avoid conflicts
struct RepurchaseRecommendationModelEngine {
    static func generateRecommendation(for product: String) -> RepurchaseRecommendationModel {
        return RepurchaseRecommendationModel(
            itemName: product,
            recommendedRepurchaseDate: Date(),
            reasoning: "Based on your past shopping patterns, you typically buy this product every 2-3 weeks. Your last purchase was on March 28, 2025."
        )
    }
} 