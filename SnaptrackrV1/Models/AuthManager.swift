import Foundation
import SwiftUI

// User model - Single definition
struct User: Codable {
    let id: String
    let email: String
    var name: String
    var profileImageURL: String?
    
    init(id: String, email: String, name: String, profileImageURL: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImageURL = profileImageURL
    }
}

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var showLogin: Bool = false
    @Published var hasCompletedOnboarding: Bool = false

    private let userDefaultsKey = "currentUser"
    private let onboardingKey = "hasCompletedOnboarding" // Use a consistent key

    init() {
        loadUserFromDefaults()
        loadOnboardingStatus() // Load initial onboarding state
    }

    private func loadUserFromDefaults() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    private func saveUserToDefaults(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    func signUp(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.isValidEmail(email) && password.count >= 6 && !name.isEmpty {
                let userId = UUID().uuidString
                let user = User(id: userId, email: email, name: name)

                // Set onboarding to false, using the helper function.
                self.setOnboardingStatus(false, forEmail: email)

                self.currentUser = user
                self.isAuthenticated = true
                self.saveUserToDefaults(user)
                self.isLoading = false

                print("DEBUG: New user signup - hasCompletedOnboarding: \(self.hasCompletedOnboarding)")
                completion(true)
            } else {
                if !self.isValidEmail(email) {
                    self.error = "Invalid email format"
                } else if password.count < 6 {
                    self.error = "Password must be at least 6 characters"
                } else {
                    self.error = "Please enter your name"
                }
                self.isLoading = false
                completion(false)
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.isValidEmail(email) && password.count >= 6 {
                let userId = UUID().uuidString
                let name = email.components(separatedBy: "@").first ?? "User"
                let user = User(id: userId, email: email, name: name)

                self.currentUser = user
                self.isAuthenticated = true
                self.saveUserToDefaults(user)

                // Load onboarding status *after* setting currentUser
                self.loadOnboardingStatus()

                self.isLoading = false
                self.showLogin = false
                completion(true)
            } else {
                self.error = "Invalid email or password"
                self.isLoading = false
                completion(false)
            }
        }
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        showLogin = true
        // Reset Onboarding *correctly*
        setOnboardingStatus(false)  // Reset for ALL users on logout
    }

    // Update user profile
    func updateUserProfile(name: String, profileImageURL: String? = nil) {
        guard var user = currentUser else { return }
        user.name = name
        if let profileImageURL = profileImageURL {
            user.profileImageURL = profileImageURL
        }
        currentUser = user
        saveUserToDefaults(user)
    }

    // Call this when the user completes the onboarding flow
    func completeOnboarding() {
        setOnboardingStatus(true) // Use the centralized function
    }

    // Helper function to LOAD onboarding status
    private func loadOnboardingStatus() {
        if let email = currentUser?.email {
            hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding_\(email)")
        } else {
            hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        }
        objectWillChange.send() // Notify SwiftUI
    }

    // Centralized setter to update onboarding, and use this in signup, logout
    func setOnboardingStatus(_ completed: Bool, forEmail email: String? = nil) {
        hasCompletedOnboarding = completed
        if let email = email ?? currentUser?.email { // Use provided email, then current user's
            UserDefaults.standard.set(completed, forKey: "hasCompletedOnboarding_\(email)")
        }
        UserDefaults.standard.set(completed, forKey: onboardingKey) // Keep the general key
        objectWillChange.send() // CRITICAL: Notify SwiftUI of the change
    }

    func updateOnboardingStatus() { //KEEP THIS, useful to refresh on auth change.
        if let email = currentUser?.email {
            hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding_\(email)")
        } else {
            // If no current user, default to false or check general flag
            hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        objectWillChange.send()
    }

    // Check if user is already logged in
    func checkForExistingUser() {
        loadUserFromDefaults()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
