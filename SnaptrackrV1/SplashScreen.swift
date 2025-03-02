import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            if isActive {
                AuthContainerView()
            } else {
                // Splash screen
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
                    
                    VStack(spacing: 20) {
                        // App logo
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                        
                        // App name
                        Text("Snaptrackr")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Loading indicator
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding(.top, 30)
                    }
                }
            }
        }
        .onAppear {
            // Simulate splash screen delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
} 
