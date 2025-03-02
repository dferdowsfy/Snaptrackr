import SwiftUI

struct HomeView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back,")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(authManager.currentUser?.name ?? "User")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Quick stats cards
                HStack(spacing: 15) {
                    // Items in inventory
                    statsCard(
                        title: "Inventory",
                        value: "24",
                        icon: "cube.box.fill",
                        color: Color(red: 84/255, green: 212/255, blue: 228/255)
                    )
                    
                    // Items expiring soon
                    statsCard(
                        title: "Expiring Soon",
                        value: "5",
                        icon: "exclamationmark.circle.fill",
                        color: Color.orange
                    )
                }
                .padding(.horizontal)
                
                // Recent activity section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Activity")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Activity list
                    VStack(spacing: 12) {
                        activityItem(
                            title: "Added Milk",
                            subtitle: "Whole Foods • $4.99",
                            time: "Today, 2:30 PM",
                            icon: "plus.circle.fill",
                            color: .green
                        )
                        
                        activityItem(
                            title: "Eggs Expiring",
                            subtitle: "Expires in 2 days",
                            time: "Today",
                            icon: "clock.fill",
                            color: .yellow
                        )
                        
                        activityItem(
                            title: "Bread Expired",
                            subtitle: "Expired yesterday",
                            time: "Yesterday",
                            icon: "exclamationmark.circle.fill",
                            color: .red
                        )
                        
                        activityItem(
                            title: "Added Apples",
                            subtitle: "Trader Joe's • $3.49",
                            time: "Yesterday, 10:15 AM",
                            icon: "plus.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal, 5)
                }
                .padding(.top, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                )
                
                // Price alerts section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Price Alerts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            priceAlertCard(
                                item: "Organic Eggs",
                                currentPrice: "$5.99",
                                lowestPrice: "$4.49",
                                store: "Whole Foods",
                                savings: "25%"
                            )
                            
                            priceAlertCard(
                                item: "Ground Beef",
                                currentPrice: "$8.99",
                                lowestPrice: "$6.99",
                                store: "Safeway",
                                savings: "22%"
                            )
                            
                            priceAlertCard(
                                item: "Avocados",
                                currentPrice: "$2.49",
                                lowestPrice: "$1.79",
                                store: "Trader Joe's",
                                savings: "28%"
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                )
                
                // Spacer for bottom padding
                Spacer(minLength: 80)
            }
        }
        .background(Color.clear)
    }
    
    // Helper function to create stats cards
    private func statsCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
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
    
    // Helper function to create activity items
    private func activityItem(title: String, subtitle: String, time: String, icon: String, color: Color) -> some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Time
            Text(time)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
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
    
    // Helper function to create price alert cards
    private func priceAlertCard(item: String, currentPrice: String, lowestPrice: String, store: String, savings: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Item name
            Text(item)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // Price comparison
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(currentPrice)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lowest")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(lowestPrice)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }
            }
            
            // Store and savings
            HStack {
                Text(store)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("Save \(savings)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(width: 220)
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

struct HomeView_Previews: PreviewProvider {
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
            
            HomeView()
        }
    }
} 