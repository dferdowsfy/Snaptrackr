import SwiftUI

struct CompareView: View {
    @State private var apiResponseData: String = "" // Store API response here
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Your existing compare UI components
                
                // Add the PriceComparisonView here
                if !apiResponseData.isEmpty {
                    PriceComparisonView(
                        productName: "Your Product Name", // Replace with actual product name
                        priceData: apiResponseData
                    )
                }
                
                // Add the "Compare All" button at the bottom
                Button("Compare All") {
                    // Your compare all action
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.bottom, 100) // Extra padding to ensure bottom content is visible
        }
    }
    
    // Function to update the apiResponseData when API call is made
    func updateWithApiResponse(_ response: String) {
        self.apiResponseData = response
    }
} 