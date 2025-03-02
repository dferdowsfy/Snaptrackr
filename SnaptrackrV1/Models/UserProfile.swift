import Foundation
import SwiftUI

struct UserProfile: Codable {
    enum HouseholdSize: String, Codable, CaseIterable {
        case one = "Just Me"
        case two = "Two People"
        case three = "Three People"
        case four = "Four People"
        case moreThanFour = "More than Four"
        
        var icon: String {
            switch self {
            case .one: return "person"
            case .two: return "person.2"
            case .three: return "person.3"
            case .four: return "person.3"
            case .moreThanFour: return "person.3"
            }
        }
    }
    
    enum CookingHabit: String, Codable, CaseIterable {
        case never = "Never Cook"
        case sometimes = "Cook Sometimes"
        case half = "Cook Half the Time"
        case mostly = "Cook Most Meals"
        case always = "Cook All Meals"
        
        var icon: String {
            switch self {
            case .never: return "takeoutbag.and.cup.and.straw"
            case .sometimes: return "fork.knife"
            case .half: return "fork.knife"
            case .mostly: return "cooktop"
            case .always: return "stove"
            }
        }
    }
    
    enum ShoppingFrequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Every Two Weeks"
        case monthly = "Monthly"
        
        var icon: String {
            switch self {
            case .daily: return "clock.badge"
            case .weekly: return "calendar.badge.clock"
            case .biweekly: return "calendar"
            case .monthly: return "calendar.circle"
            }
        }
    }
    
    enum WorkFromHome: String, Codable, CaseIterable {
        case yes = "Yes"
        case no = "No"
        case hybrid = "Hybrid"
        
        var icon: String {
            switch self {
            case .yes: return "house"
            case .no: return "building.2"
            case .hybrid: return "building.2.and.person"
            }
        }
    }
    
    enum RegularPurchase: String, Codable, CaseIterable, Hashable {
        case groceries = "Groceries"
        case personalCare = "Personal Care"
        case householdItems = "Household Items"
        case petSupplies = "Pet Supplies"
        case officeSupplies = "Office Supplies"
        case none = "None of these"
        
        var icon: String {
            switch self {
            case .groceries: return "🛒"
            case .personalCare: return "🧴"
            case .householdItems: return "🏠"
            case .petSupplies: return "🐾"
            case .officeSupplies: return "✏️"
            case .none: return "❌"
            }
        }
    }
    
    var householdSize: HouseholdSize
    var cookingHabit: CookingHabit
    var shoppingFrequency: ShoppingFrequency
    var workFromHome: WorkFromHome
    var regularPurchases: Set<RegularPurchase>
}

// Add a UserProfileManager to store the profile
class UserProfileManager {
    static let shared = UserProfileManager()
    
    var profile: UserProfile?
    var hasCompletedOnboarding: Bool = false
    
    private init() {
        // Load profile from UserDefaults if available
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let savedProfile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = savedProfile
            self.hasCompletedOnboarding = true
        }
    }
    
    func saveProfile(_ profile: UserProfile) {
        self.profile = profile
        self.hasCompletedOnboarding = true
        
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
} 