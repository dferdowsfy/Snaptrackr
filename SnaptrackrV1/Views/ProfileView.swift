import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showingLogoutAlert = false
    @State private var showingEditProfile = false
    @State private var selectedCurrency = "USD"
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true
    @State private var biometricEnabled = false
    
    let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Profile header
                VStack(spacing: 15) {
                    // Profile image
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 68/255, green: 36/255, blue: 164/255),
                                        Color(red: 84/255, green: 212/255, blue: 228/255)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.5), radius: 10, x: 0, y: 0)
                        
                        Text(getInitials())
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // User name
                    Text(authManager.currentUser?.name ?? "User")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    // User email
                    Text(authManager.currentUser?.email ?? "user@example.com")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                    
                    // Edit profile button
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Text("Edit Profile")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.regularMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
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
                    }
                    .padding(.top, 5)
                }
                .padding(.top, 20)
                
                // Settings sections
                VStack(spacing: 20) {
                    // Account settings
                    settingsSection(title: "Account Settings") {
                        // Currency setting
                        settingsRow(icon: "dollarsign.circle.fill", title: "Currency") {
                            Picker("Currency", selection: $selectedCurrency) {
                                ForEach(currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .foregroundColor(.white)
                        }
                        
                        // Notifications setting
                        settingsRow(icon: "bell.fill", title: "Notifications") {
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 84/255, green: 212/255, blue: 228/255)))
                        }
                        
                        // Dark mode setting
                        settingsRow(icon: "moon.fill", title: "Dark Mode") {
                            Toggle("", isOn: $darkModeEnabled)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 84/255, green: 212/255, blue: 228/255)))
                        }
                        
                        // Biometric authentication setting
                        settingsRow(icon: "faceid", title: "Biometric Authentication") {
                            Toggle("", isOn: $biometricEnabled)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 84/255, green: 212/255, blue: 228/255)))
                        }
                    }
                    
                    // Support section
                    settingsSection(title: "Support") {
                        // Help center
                        settingsRow(icon: "questionmark.circle.fill", title: "Help Center") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // Contact us
                        settingsRow(icon: "envelope.fill", title: "Contact Us") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // Privacy policy
                        settingsRow(icon: "lock.fill", title: "Privacy Policy") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // Terms of service
                        settingsRow(icon: "doc.text.fill", title: "Terms of Service") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    // App info section
                    settingsSection(title: "App Info") {
                        // Version
                        settingsRow(icon: "info.circle.fill", title: "Version") {
                            Text("1.0.0")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // Rate app
                        settingsRow(icon: "star.fill", title: "Rate App") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // Share app
                        settingsRow(icon: "square.and.arrow.up.fill", title: "Share App") {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    // Logout button
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                                .font(.system(size: 20))
                            
                            Text("Logout")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.red.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
                
                // Spacer for bottom padding
                Spacer(minLength: 80)
            }
        }
        .background(Color.clear)
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Logout")) {
                    authManager.logout()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
    
    // Helper function to get user initials
    private func getInitials() -> String {
        guard let name = authManager.currentUser?.name else { return "U" }
        
        let components = name.components(separatedBy: " ")
        if components.count > 1, let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)"
        } else if let first = components.first?.first {
            return "\(first)"
        }
        
        return "U"
    }
    
    // Helper function to create settings sections
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 5)
            
            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
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
        }
    }
    
    // Helper function to create settings rows
    private func settingsRow<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(Color.clear)
    }
}

// Edit Profile View
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authManager = AuthManager.shared
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 68/255, green: 36/255, blue: 164/255),
                        Color(red: 84/255, green: 212/255, blue: 228/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile image
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            ZStack {
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                } else {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 68/255, green: 36/255, blue: 164/255),
                                                    Color(red: 84/255, green: 212/255, blue: 228/255)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                    
                                    Text(getInitials())
                                        .font(.system(size: 50, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                // Camera icon overlay
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 35, height: 35)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 40, y: 40)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Form fields
                        VStack(spacing: 20) {
                            // Name field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Enter your name", text: $name)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                            
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Enter your email", text: $email)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .disabled(true) // Email cannot be changed
                                    .opacity(0.7)
                            }
                            
                            // Save button
                            Button(action: {
                                saveProfile()
                            }) {
                                Text("Save Changes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                .onAppear {
                    // Load current user data
                    if let user = authManager.currentUser {
                        name = user.name
                        email = user.email
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    // Helper function to get user initials
    private func getInitials() -> String {
        guard let name = authManager.currentUser?.name else { return "U" }
        
        let components = name.components(separatedBy: " ")
        if components.count > 1, let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)"
        } else if let first = components.first?.first {
            return "\(first)"
        }
        
        return "U"
    }
    
    // Save profile changes
    private func saveProfile() {
        // In a real app, you would update the user profile in your backend
        if let user = authManager.currentUser {
            // Update local user data
            authManager.updateUserProfile(name: name)
        }
        
        // Dismiss the edit profile view
        presentationMode.wrappedValue.dismiss()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 68/255, green: 36/255, blue: 164/255),
                    Color(red: 84/255, green: 212/255, blue: 228/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ProfileView()
        }
    }
} 