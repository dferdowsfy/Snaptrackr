import SwiftUI

struct HomeDashboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Your existing dashboard content
                
                // Category Chart
                CategoryChartView()
                    .padding(.horizontal)
                
                // Other dashboard elements
            }
        }
    }
}

struct HomeDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDashboardView()
    }
} 
#Preview {
    HomeDashboardView()
}
