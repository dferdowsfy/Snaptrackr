import SwiftUI

// Define the view model as a class that conforms to ObservableObject
class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var selectedHouseholdSize: UserProfile.HouseholdSize?
    @Published var selectedCookingHabit: UserProfile.CookingHabit?
    @Published var selectedShoppingFrequency: UserProfile.ShoppingFrequency?
    @Published var selectedWorkFromHome: UserProfile.WorkFromHome?
    @Published var selectedRegularPurchases: Set<UserProfile.RegularPurchase> = []
    @Published var showError: Bool = false
    
    func canProceedFromCurrentPage() -> Bool {
        switch currentPage {
        case 0:
            return selectedHouseholdSize != nil
        case 1:
            return selectedCookingHabit != nil
        case 2:
            return selectedShoppingFrequency != nil
        case 3:
            return selectedWorkFromHome != nil
        case 4:
            return !selectedRegularPurchases.isEmpty
        default:
            return true
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthManager // Get AuthManager from the environment
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        // ... (your existing OnboardingView UI code - no changes needed here) ...
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(viewModel.currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 40)
                
                // Page content
                TabView(selection: $viewModel.currentPage) {
                    householdSizeView
                        .tag(0)
                    
                    cookingHabitView
                        .tag(1)
                    
                    shoppingFrequencyView
                        .tag(2)
                    
                    workFromHomeView
                        .tag(3)
                    
                    regularPurchasesView
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentPage)
                
                // Navigation buttons
                HStack {
                    if viewModel.currentPage > 0 {
                        Button(action: {
                            viewModel.currentPage -= 1
                        }) {
                            Text("Back")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 100)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.canProceedFromCurrentPage() {
                            if viewModel.currentPage < 4 {
                                viewModel.currentPage += 1
                            } else {
                                completeOnboarding()
                            }
                        } else {
                            viewModel.showError = true
                        }
                    }) {
                        Text(viewModel.currentPage == 4 ? "Complete" : "Next")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .padding()
        }
        .alert("Please Make a Selection", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please select at least one option to continue.")
        }
        .interactiveDismissDisabled() // Prevent dismissing the onboarding
    }
    
    private var householdSizeView: some View {
        VStack(spacing: 30) {
            Text("How many people are in your household?")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(UserProfile.HouseholdSize.allCases, id: \.self) { size in
                    selectionButton(
                        icon: size.icon,
                        title: size.rawValue,
                        isSelected: viewModel.selectedHouseholdSize == size
                    ) {
                        viewModel.selectedHouseholdSize = size
                    }
                }
            }
        }
    }
    
    private var cookingHabitView: some View {
        VStack(spacing: 30) {
            Text("How often do you cook at home?")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(UserProfile.CookingHabit.allCases, id: \.self) { habit in
                    selectionButton(
                        icon: habit.icon,
                        title: habit.rawValue,
                        isSelected: viewModel.selectedCookingHabit == habit
                    ) {
                        viewModel.selectedCookingHabit = habit
                    }
                }
            }
        }
    }
    
    private var shoppingFrequencyView: some View {
        VStack(spacing: 30) {
            Text("How often do you go grocery shopping?")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(UserProfile.ShoppingFrequency.allCases, id: \.self) { frequency in
                    selectionButton(
                        icon: frequency.icon,
                        title: frequency.rawValue,
                        isSelected: viewModel.selectedShoppingFrequency == frequency
                    ) {
                        viewModel.selectedShoppingFrequency = frequency
                    }
                }
            }
        }
    }
    
    private var workFromHomeView: some View {
        VStack(spacing: 30) {
            Text("Does anyone in your household work from home?")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(UserProfile.WorkFromHome.allCases, id: \.self) { option in
                    selectionButton(
                        icon: option.icon,
                        title: option.rawValue,
                        isSelected: viewModel.selectedWorkFromHome == option
                    ) {
                        viewModel.selectedWorkFromHome = option
                    }
                }
            }
        }
    }
    
    private var regularPurchasesView: some View {
        VStack(spacing: 30) {
            Text("Which of these do you regularly buy?")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            Text("Select all that apply")
                .font(.system(size: 19, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(Array(UserProfile.RegularPurchase.allCases), id: \.self) { purchase in
                    multiSelectionButton(
                        icon: purchase.icon,
                        title: purchase.rawValue,
                        isSelected: viewModel.selectedRegularPurchases.contains(purchase)
                    ) {
                        if viewModel.selectedRegularPurchases.contains(purchase) {
                            viewModel.selectedRegularPurchases.remove(purchase)
                        } else {
                            // If selecting "None", clear other selections
                            if purchase == .none {
                                viewModel.selectedRegularPurchases = [.none]
                            } else {
                                // If selecting something else, remove "None" if present
                                viewModel.selectedRegularPurchases.remove(.none)
                                viewModel.selectedRegularPurchases.insert(purchase)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func selectionButton(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                if isSelected {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.purple : Color.blue.opacity(0.7))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func multiSelectionButton(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.system(size: 24))
                    .padding(.trailing, 8)
                
                Text(title)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func completeOnboarding() {
        guard let householdSize = viewModel.selectedHouseholdSize,
              let cookingHabit = viewModel.selectedCookingHabit,
              let shoppingFrequency = viewModel.selectedShoppingFrequency,
              let workFromHome = viewModel.selectedWorkFromHome,
              !viewModel.selectedRegularPurchases.isEmpty else {
            viewModel.showError = true
            return
        }
        
        // Create and save user profile
        let profile = UserProfile(
            householdSize: householdSize,
            cookingHabit: cookingHabit,
            shoppingFrequency: shoppingFrequency,
            workFromHome: workFromHome,
            regularPurchases: viewModel.selectedRegularPurchases
        )
        
        // Save profile to UserProfileManager
        UserProfileManager.shared.saveProfile(profile)
        
        // Mark onboarding as complete in AuthManager
        authManager.completeOnboarding()
        
        print("DEBUG: Onboarding completed - hasCompletedOnboarding: \(authManager.hasCompletedOnboarding)")
        
        dismiss()
    }
}
#Preview {
    OnboardingView()
}
