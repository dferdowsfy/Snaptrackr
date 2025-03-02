import SwiftUI

struct SettingsView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Page title
                Text("Settings")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                // User profile section
                if let user = authManager.currentUser {
                    GroupBox(label: Text("Profile").foregroundColor(.white)) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                // Profile image
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 70, height: 70)
                                    
                                    Text(String(user.name.prefix(1)).uppercased())
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(user.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Edit profile action
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                            }
                            
                            Divider().background(Color.white.opacity(0.3))
                            
                            Button(action: {
                                showLogoutConfirmation = true
                            }) {
                                Label("Logout", systemImage: "arrow.right.square")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding()
                    .groupBoxStyle(TransparentGroupBoxStyle())
                    .padding(.horizontal)
                }
                
                // Settings sections
                GroupBox(label: Text("Preferences").foregroundColor(.white)) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .foregroundColor(.white)
                    
                    Divider().background(Color.white.opacity(0.3))
                    
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .foregroundColor(.white)
                }
                .padding()
                .groupBoxStyle(TransparentGroupBoxStyle())
                .padding(.horizontal)
                
                // App info
                GroupBox(label: Text("About").foregroundColor(.white)) {
                    Label("App Version: 1.0.0", systemImage: "info.circle")
                        .foregroundColor(.white)
                    
                    Divider().background(Color.white.opacity(0.3))
                    
                    Button(action: {
                        // Show about screen
                    }) {
                        Label("About Snaptrackr", systemImage: "doc.text")
                            .foregroundColor(.white)
                    }
                    
                    Divider().background(Color.white.opacity(0.3))
                    
                    Button(action: {
                        // Show privacy policy
                    }) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .groupBoxStyle(TransparentGroupBoxStyle())
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .alert(isPresented: $showLogoutConfirmation) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Logout")) {
                    authManager.logout()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

// Custom transparent group box style
struct TransparentGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                configuration.label
                    .padding(.leading, 10)
                    .padding(.top, -10),
                alignment: .topLeading
            )
    }
} 