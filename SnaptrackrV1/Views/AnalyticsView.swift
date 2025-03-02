import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        ZStack {
            // Background
            Color.purple
                .opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack {
                Text("Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Text("Coming Soon")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
} 