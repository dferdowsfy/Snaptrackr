import SwiftUI

struct CustomNavigationBarModifier: ViewModifier {
    init() {
        let appearance = UINavigationBarAppearance()
        
        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .radial
        gradientLayer.colors = [
            UIColor(red: 37/255, green: 89/255, blue: 222/255, alpha: 1.0).cgColor,
            UIColor(red: 37/255, green: 89/255, blue: 222/255, alpha: 1.0).cgColor,
            UIColor(red: 4/255, green: 4/255, blue: 29/255, alpha: 1.0).cgColor
        ]
        
        // Set the gradient locations to match the specified percentages
        gradientLayer.locations = [0.0, 0.075, 0.447]
        
        // Set the start and end points to create a radial effect
        // The values are approximations of the CSS radial-gradient
        gradientLayer.startPoint = CGPoint(x: 0.052, y: 0.072) // 5.2% 7.2%
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        // Create a UIImage from the gradient layer
        let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: 1, height: 1))
        let gradientImage = renderer.image { ctx in
            gradientLayer.frame = ctx.format.bounds
            gradientLayer.render(in: ctx.cgContext)
        }
        
        // Apply the gradient image to the navigation bar background
        appearance.backgroundImage = gradientImage
        
        // Configure other appearance settings
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Remove the bottom border
        appearance.shadowColor = .clear
        
        // Apply the appearance to all navigation bar styles
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set the tint color for navigation bar items
        UINavigationBar.appearance().tintColor = .white
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func customNavigationBar() -> some View {
        self.modifier(CustomNavigationBarModifier())
    }
} 