import SwiftUI

struct ExpandableTabItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let tab: Int
    var isSeparator: Bool = false
}

struct ExpandableTabBar: View {
    @Binding var selectedTab: Int
    @State private var expandedTab: Int? = nil
    let tabs: [ExpandableTabItem]
    var onTabSelected: ((Int) -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs) { tab in
                if tab.isSeparator {
                    // Separator
                    Rectangle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 1, height: 24)
                        .padding(.horizontal, 4)
                } else {
                    // Tab button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if expandedTab == tab.tab {
                                expandedTab = nil
                            } else {
                                expandedTab = tab.tab
                                selectedTab = tab.tab
                                onTabSelected?(tab.tab)
                            }
                        }
                    }) {
                        HStack(spacing: expandedTab == tab.tab ? 8 : 0) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedTab == tab.tab ? .blue : .black)
                            
                            if expandedTab == tab.tab {
                                Text(tab.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale),
                                        removal: .opacity.combined(with: .scale)
                                    ))
                            }
                        }
                        .padding(.horizontal, expandedTab == tab.tab ? 12 : 8)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTab == tab.tab ? Color.gray.opacity(0.15) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedTab == tab.tab ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Material.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
} 