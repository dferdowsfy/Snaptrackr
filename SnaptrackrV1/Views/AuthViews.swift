import SwiftUI

// Login View
struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var isSecured = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 68/255, green: 36/255, blue: 164/255),
                        Color(red: 84/255, green: 212/255, blue: 228/255)
                    ]),
                    center: .init(x: 0.002, y: 0.005),
                    startRadius: 0,
                    endRadius: 1000
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // App logo and title
                    VStack(spacing: 10) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("Snaptrackr")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Track your grocery inventory with ease")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 50)
                    
                    // Login form
                    VStack(spacing: 20) {
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
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                if isSecured {
                                    SecureField("Enter your password", text: $password)
                                        .padding()
                                        .foregroundColor(.white)
                                } else {
                                    TextField("Enter your password", text: $password)
                                        .padding()
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: {
                                    isSecured.toggle()
                                }) {
                                    Image(systemName: isSecured ? "eye.slash" : "eye")
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing, 10)
                            }
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        // Error message
                        if let error = authManager.error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Login button
                        Button(action: {
                            authManager.login(email: email, password: password) { _ in
                                // Success handled by the published isAuthenticated property
                            }
                        }) {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.3))
                                    .cornerRadius(10)
                            } else {
                                Text("Login")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.3))
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(authManager.isLoading)
                        
                        // Sign up button
                        Button(action: {
                            showSignUp = true
                        }) {
                            Text("Don't have an account? Sign Up")
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

// Sign Up View
struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authManager = AuthManager.shared
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSecured = true
    @State private var isConfirmSecured = true
    
    var body: some View {
        ZStack {
            // Background gradient
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 68/255, green: 36/255, blue: 164/255),
                    Color(red: 84/255, green: 212/255, blue: 228/255)
                ]),
                center: .init(x: 0.002, y: 0.005),
                startRadius: 0,
                endRadius: 1000
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                Text("Create Account")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                // Sign up form
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
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            if isSecured {
                                SecureField("Enter your password", text: $password)
                                    .padding()
                                    .foregroundColor(.white)
                            } else {
                                TextField("Enter your password", text: $password)
                                    .padding()
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                isSecured.toggle()
                            }) {
                                Image(systemName: isSecured ? "eye.slash" : "eye")
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 10)
                        }
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    // Confirm Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            if isConfirmSecured {
                                SecureField("Confirm your password", text: $confirmPassword)
                                    .padding()
                                    .foregroundColor(.white)
                            } else {
                                TextField("Confirm your password", text: $confirmPassword)
                                    .padding()
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                isConfirmSecured.toggle()
                            }) {
                                Image(systemName: isConfirmSecured ? "eye.slash" : "eye")
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 10)
                        }
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    // Error message
                    if let error = authManager.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    } else if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Passwords do not match")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Sign up button
                    Button(action: {
                        if password == confirmPassword {
                            authManager.signUp(name: name, email: email, password: password) { success in
                                if success {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }) {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(10)
                        } else {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(10)
                        }
                    }
                    .disabled(authManager.isLoading || password != confirmPassword || name.isEmpty || email.isEmpty || password.isEmpty)
                    
                    // Back to login button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Already have an account? Login")
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
    }
}

// Auth Container View to handle authentication state
struct AuthContainerView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if !authManager.isAuthenticated {
                LoginView()
            } else if !authManager.hasCompletedOnboarding {
                OnboardingView()
                    .environmentObject(authManager)
            } else {
                ModernMainView()
            }
        }
    }
} 