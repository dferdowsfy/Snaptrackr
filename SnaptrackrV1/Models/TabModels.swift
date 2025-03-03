import SwiftUI

// Renamed to avoid conflicts
struct AppTabItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let tab: Int
    var isSeparator: Bool = false
}

// Renamed to avoid conflicts
struct AppScannerOption: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
} 