import SwiftUI

struct AppGradients {
    // Main card gradient - blue radial gradient
    static var cardBackground: some ShapeStyle {
        RadialGradient(
            gradient: Gradient(colors: [
                Color(red: 44/255, green: 103/255, blue: 176/255),
                Color(red: 35/255, green: 56/255, blue: 136/255)
            ]),
            center: .init(x: 0.025, y: 0.08), // 2.5% 8%
            startRadius: 0,
            endRadius: 950
        )
    }
} 