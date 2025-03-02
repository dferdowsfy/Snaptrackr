import SwiftUI
import UIKit

struct ModernTabBar: View {
    @Binding var selectedTab: Int
    @State private var scannerHubExpanded = false
    
    // Define tab items
    let tabItems = [
        TabItem(icon: "house.fill", title: "Home", tab: 0),
        TabItem(icon: "cube.box.fill", title: "Inventory", tab: 1),
        TabItem(icon: "chart.bar.fill", title: "Analytics", tab: 2),
        TabItem(icon: "person.fill", title: "Profile", tab: 3)
    ]
    
    // Scanner hub options - keep only Barcode and Receipt
    let scannerOptions = [
        ScannerOption(icon: "barcode.viewfinder", title: "Barcode", color: .blue),
        ScannerOption(icon: "doc.text.viewfinder", title: "Receipt", color: .green)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab Bar - completely transparent, no background
            // Anchored at the bottom with fixed position
            HStack(spacing: 0) {
                ForEach(tabItems) { item in
                    Button {
                        selectedTab = item.tab
                    } label: {
                        VStack(spacing: 9) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedTab == item.tab ? .white : .white.opacity(0.5))
                            
                            Text(item.title)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(selectedTab == item.tab ? .white : .white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        // Only highlight the selected tab with a subtle glow
                        .overlay(
                            selectedTab == item.tab ?
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 68/255, green: 36/255, blue: 164/255).opacity(0.5),
                                            Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.5)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 3)
                                .padding(.top, 60)
                            : nil
                        )
                    }
                }
            }
            .frame(height: 90)
            .zIndex(1) // Ensure nav bar stays on top
            
            // Floating Scanner Hub Button and Options
            // Positioned relative to the nav bar
            ZStack {
                // No background when options are expanded - completely removed

                // Scanner options (displayed when expanded)
                if scannerHubExpanded {
                    ForEach(Array(scannerOptions.enumerated()), id: \.element.id) { index, option in
                        let angle = Double(index) * (360.0 / Double(scannerOptions.count))
                        let radians = angle * .pi / 180
                        let radius: CGFloat = 120
                        let x = cos(radians) * radius
                        let y = sin(radians) * radius - 45 // Offset to position relative to nav bar
                        
                        Button {
                            handleScannerOptionTap(option)
                        } label: {
                            ZStack {
                                // Button background with blur
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(option.color.opacity(0.6), lineWidth: 1)
                                    )
                                    .shadow(color: option.color.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                VStack(spacing: 8) {
                                    Image(systemName: option.icon)
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(option.color)
                                    
                                    Text(option.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                .padding(16)
                            }
                            .frame(width: 100, height: 100)
                        }
                        .offset(x: x, y: y)
                        .scaleEffect(scannerHubExpanded ? 1 : 0)
                        .opacity(scannerHubExpanded ? 1 : 0)
                        .animation(
                            .spring(
                                response: 0.4,
                                dampingFraction: 0.7,
                                blendDuration: 0.3
                            )
                            .delay(Double(index) * 0.1),
                            value: scannerHubExpanded
                        )
                    }
                }
                
                // Main scanner button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        scannerHubExpanded.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 68/255, green: 36/255, blue: 164/255),
                                                Color(red: 84/255, green: 212/255, blue: 228/255)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.3), radius: 10, x: 0, y: 4)
                        
                        Image(systemName: "viewfinder")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(width: 60, height: 60)
                }
                .offset(y: -30)
                .zIndex(2) // Ensure scan button stays on top
            }
        }
        // Add tap gesture to dismiss options when tapping anywhere else
        .contentShape(Rectangle())
        .onTapGesture {
            if scannerHubExpanded {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    scannerHubExpanded = false
                }
            }
        }
    }
    
    // Handle scanner option taps
    private func handleScannerOptionTap(_ option: ScannerOption) {
        // Close the hub first
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scannerHubExpanded = false
        }
        
        // Add a slight delay before showing the scanner
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Launch the appropriate scanner based on the option
            switch option.title {
            case "Barcode":
                // Launch barcode scanner camera with Perplexity API for price comparison
                NotificationCenter.default.post(name: NSNotification.Name("OpenBarcodeScanner"), object: nil)
                
            case "Receipt":
                // Launch receipt scanner camera with Google Gemini API for receipt parsing
                NotificationCenter.default.post(name: NSNotification.Name("OpenReceiptScanner"), object: nil)
                
            default:
                break
            }
        }
    }
}

// Tab Item Model
struct TabItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let tab: Int
}

// Scanner Option Model
struct ScannerOption: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
}

struct ModernTabBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                ModernTabBar(selectedTab: .constant(0))
            }
        }
    }
} 
