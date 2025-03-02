import SwiftUI

struct RepurchaseRecommendationView: View {
    let itemName: String
    @State private var recommendation: RepurchaseRecommendation?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Repurchase Recommendation")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                if isLoading {
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
                } else if let recommendation = recommendation {
                    // Product card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Product")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(recommendation.itemName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }

                            Spacer()

                            Image(systemName: getCategoryIcon(for: recommendation.itemName))
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }

                        Divider()

                        // Recommendation date
                        VStack(alignment: .leading) {
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

                        Divider()

                        // Reasoning
                        VStack(alignment: .leading) {
                            Text("Reasoning")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(recommendation.reasoning)
                                .font(.body)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                    // Factors that influenced this recommendation
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Factors Considered")
                            .font(.headline)
                            .padding(.top)

                        // Household size
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)

                            VStack(alignment: .leading) {
                                Text("Household Size")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if let profile = UserProfileManager.shared.profile {
                                    Text(profile.householdSize.rawValue)
                                        .font(.body)
                                } else {
                                    Text("Not set")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Cooking habits
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.orange)
                                .frame(width: 30)

                            VStack(alignment: .leading) {
                                Text("Cooking Habits")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if let profile = UserProfileManager.shared.profile {
                                    Text(profile.cookingHabit.rawValue)
                                        .font(.body)
                                } else {
                                    Text("Not set")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Shopping frequency
                        HStack {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)

                            VStack(alignment: .leading) {
                                Text("Shopping Frequency")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if let profile = UserProfileManager.shared.profile {
                                    Text(profile.shoppingFrequency.rawValue)
                                        .font(.body)
                                } else {
                                    Text("Not set")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Work from home
                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)

                            VStack(alignment: .leading) {
                                Text("Work From Home")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if let profile = UserProfileManager.shared.profile {
                                    Text(profile.workFromHome.rawValue)
                                        .font(.body)
                                } else {
                                    Text("Not set")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                    // Add to calendar button
                    Button(action: {
                        // Add to calendar functionality would go here
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Add to Calendar")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                } else {
                    // Error state
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
            }
            .padding()
        }
        .onAppear {
            // Generate recommendation when view appears
            generateRecommendation()
        }
    }

    private func generateRecommendation() {
        // Simulate loading
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

// Model for repurchase recommendation
struct RepurchaseRecommendation: Codable {
    enum Confidence: String, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    let itemName: String
    let daysUntilRepurchase: Int
    let confidence: Confidence
    
    // Computed properties
    var repurchaseDate: String {
        let date = Calendar.current.date(byAdding: .day, value: daysUntilRepurchase, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var reasoning: String {
        "Based on your household profile and purchase history, you'll likely need to repurchase \(itemName) in \(daysUntilRepurchase) days."
    }
}

// Engine to generate repurchase recommendations
struct RepurchaseRecommendationEngine {
    static func generateRecommendation(for itemName: String) -> RepurchaseRecommendation {
        guard let profile = UserProfileManager.shared.profile else {
            // Default recommendation if no profile exists
            return RepurchaseRecommendation(
                itemName: itemName,
                daysUntilRepurchase: 7,
                confidence: .medium
            )
        }

        // Calculate base repurchase interval based on product type
        let baseInterval = calculateBaseInterval(for: itemName)

        // Apply modifiers based on user profile
        let householdModifier = getHouseholdSizeModifier(profile.householdSize)
        let cookingModifier = getCookingHabitModifier(profile.cookingHabit)

        // Get days between shopping trips
        let shoppingFrequencyDays = getShoppingFrequencyDays(profile.shoppingFrequency)
        
        // Convert to a modifier (weekly = 1.0 baseline)
        let shoppingModifier = 7.0 / Double(shoppingFrequencyDays)
        
        let workFromHomeModifier = getWorkFromHomeModifier(profile.workFromHome)
        let regularPurchasesModifier = calculateRegularPurchasesModifier(for: itemName, in: profile)
        
        // Calculate final repurchase interval
        let finalInterval = baseInterval * householdModifier * cookingModifier * shoppingModifier * workFromHomeModifier * regularPurchasesModifier
        
        // Convert to days
        let daysUntilRepurchase = Int(round(finalInterval))
        
        // Determine confidence level
        let confidence = determineConfidence(baseInterval: baseInterval, finalInterval: finalInterval)
        
        // Generate recommendation
        return RepurchaseRecommendation(
            itemName: itemName,
            daysUntilRepurchase: daysUntilRepurchase,
            confidence: confidence
        )
    }
    
    // Helper methods to get the modifiers
    private static func getHouseholdSizeModifier(_ size: UserProfile.HouseholdSize) -> Double {
        switch size {
        case .one: return 1.0
        case .two: return 1.5
        case .three: return 2.0
        case .four: return 2.5
        case .moreThanFour: return 3.0
        }
    }
    
    private static func getCookingHabitModifier(_ habit: UserProfile.CookingHabit) -> Double {
        switch habit {
        case .never: return 0.5
        case .sometimes: return 0.8
        case .half: return 1.0
        case .mostly: return 1.2
        case .always: return 1.5
        }
    }
    
    private static func getShoppingFrequencyDays(_ frequency: UserProfile.ShoppingFrequency) -> Int {
        switch frequency {
        case .daily: return 1
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        }
    }
    
    private static func getWorkFromHomeModifier(_ workFromHome: UserProfile.WorkFromHome) -> Double {
        switch workFromHome {
        case .no: return 0.9
        case .hybrid: return 1.1
        case .yes: return 1.3
        }
    }
    
    private static func calculateBaseInterval(for itemName: String) -> Double {
        // Simple logic based on item name
        let lowercaseName = itemName.lowercased()
        
        if lowercaseName.contains("milk") || lowercaseName.contains("bread") {
            return 3.0 // Days for staples
        } else if lowercaseName.contains("fruit") || lowercaseName.contains("vegetable") {
            return 5.0 // Days for fresh produce
        } else if lowercaseName.contains("meat") || lowercaseName.contains("fish") {
            return 4.0 // Days for proteins
        } else if lowercaseName.contains("toilet") || lowercaseName.contains("paper") {
            return 14.0 // Days for household items
        } else {
            return 7.0 // Default interval
        }
    }
    
    private static func calculateRegularPurchasesModifier(for itemName: String, in profile: UserProfile) -> Double {
        // Check if the item category is in the user's regular purchases
        let lowercaseName = itemName.lowercased()
        
        if lowercaseName.contains("grocery") && profile.regularPurchases.contains(.groceries) {
            return 0.8 // Faster repurchase for regular items
        } else if lowercaseName.contains("care") && profile.regularPurchases.contains(.personalCare) {
            return 0.8
        } else if (lowercaseName.contains("house") || lowercaseName.contains("clean")) && profile.regularPurchases.contains(.householdItems) {
            return 0.8
        } else if (lowercaseName.contains("pet") || lowercaseName.contains("dog") || lowercaseName.contains("cat")) && profile.regularPurchases.contains(.petSupplies) {
            return 0.8
        } else if (lowercaseName.contains("office") || lowercaseName.contains("paper")) && profile.regularPurchases.contains(.officeSupplies) {
            return 0.8
        } else {
            return 1.0 // No modifier for non-regular items
        }
    }
    
    private static func determineConfidence(baseInterval: Double, finalInterval: Double) -> RepurchaseRecommendation.Confidence {
        let difference = abs(baseInterval - finalInterval)
        
        if difference < 1.0 {
            return .high
        } else if difference < 3.0 {
            return .medium
        } else {
            return .low
        }
    }
}
