import SwiftUI

struct ChatbotBubble: View {
    @State private var isExpanded = false
    @State private var messages: [ChatMessage] = []
    @State private var newMessage = ""
    @State private var isTyping = false
    
    var body: some View {
        VStack {
            if isExpanded {
                // Expanded chat view
                VStack(spacing: 0) {
                    // Chat header
                    HStack {
                        // Bot avatar
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 68/255, green: 36/255, blue: 164/255),
                                        Color(red: 84/255, green: 212/255, blue: 228/255)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Snaptrackr Assistant")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(isTyping ? "Typing..." : "Online")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Close button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isExpanded = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 68/255, green: 36/255, blue: 164/255),
                                Color(red: 84/255, green: 212/255, blue: 228/255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Messages list
                    ScrollViewReader { scrollView in
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                // Welcome message
                                if messages.isEmpty {
                                    botMessage("Hi there! I'm your Snaptrackr Assistant. How can I help you today?")
                                        .id("welcome")
                                }
                                
                                // Chat messages
                                ForEach(messages) { message in
                                    if message.isFromUser {
                                        userMessage(message.text)
                                            .id(message.id)
                                    } else {
                                        botMessage(message.text)
                                            .id(message.id)
                                    }
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _ in
                            if let lastMessage = messages.last {
                                withAnimation {
                                    scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .frame(height: 300)
                    .background(Color(UIColor.systemBackground).opacity(0.9))
                    
                    // Quick suggestions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            suggestionButton("How to scan barcodes?")
                            suggestionButton("Track my spending")
                            suggestionButton("Find best prices")
                            suggestionButton("Manage inventory")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .background(Color(UIColor.secondarySystemBackground).opacity(0.9))
                    
                    // Message input
                    HStack {
                        TextField("Type a message...", text: $newMessage)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                            .padding(.leading)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color(red: 84/255, green: 212/255, blue: 228/255))
                        }
                        .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.trailing)
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemBackground).opacity(0.9))
                }
                .frame(width: 350)
                .background(Color.white.opacity(0.95))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                .offset(x: -20, y: -20) // Position in bottom right, but with some offset
            } else {
                // Collapsed chat bubble
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 68/255, green: 36/255, blue: 164/255),
                                        Color(red: 84/255, green: 212/255, blue: 228/255)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.5), radius: 10, x: 0, y: 0)
                        
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.trailing, 20)
        .padding(.bottom, 80) // Position above the tab bar
    }
    
    // User message bubble
    private func userMessage(_ text: String) -> some View {
        HStack {
            Spacer()
            
            Text(text)
                .padding(12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 68/255, green: 36/255, blue: 164/255),
                            Color(red: 84/255, green: 212/255, blue: 228/255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(18)
                .cornerRadius(18, corners: [.topRight, .bottomLeft, .bottomRight])
        }
    }
    
    // Bot message bubble
    private func botMessage(_ text: String) -> some View {
        HStack {
            // Bot avatar
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 68/255, green: 36/255, blue: 164/255),
                            Color(red: 84/255, green: 212/255, blue: 228/255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                )
            
            Text(text)
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .foregroundColor(Color(UIColor.label))
                .cornerRadius(18)
                .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
            
            Spacer()
        }
    }
    
    // Quick suggestion button
    private func suggestionButton(_ text: String) -> some View {
        Button(action: {
            newMessage = text
            sendMessage()
        }) {
            Text(text)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.tertiarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 68/255, green: 36/255, blue: 164/255).opacity(0.5),
                                            Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.5)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .foregroundColor(Color(UIColor.label))
        }
    }
    
    // Send message function
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(text: trimmedMessage, isFromUser: true)
        messages.append(userMessage)
        newMessage = ""
        
        // Simulate bot typing
        isTyping = true
        
        // Simulate bot response after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            
            // Add bot response based on user message
            let botResponse = generateBotResponse(for: trimmedMessage)
            let botMessage = ChatMessage(text: botResponse, isFromUser: false)
            messages.append(botMessage)
        }
    }
    
    // Generate bot response based on user message
    private func generateBotResponse(for message: String) -> String {
        let lowercasedMessage = message.lowercased()
        
        if lowercasedMessage.contains("scan") || lowercasedMessage.contains("barcode") {
            return "To scan a barcode, tap the scanner button in the center of the tab bar, then select 'Barcode' from the options. Hold your camera over the barcode until it's detected."
        } else if lowercasedMessage.contains("spend") || lowercasedMessage.contains("analytics") {
            return "You can track your spending in the Analytics tab. It shows your spending patterns by category, store, and over time."
        } else if lowercasedMessage.contains("price") || lowercasedMessage.contains("best") || lowercasedMessage.contains("cheap") {
            return "To find the best prices, go to an item in your inventory and tap 'Compare Prices'. This will show you where the item is available for the lowest price."
        } else if lowercasedMessage.contains("inventory") || lowercasedMessage.contains("manage") {
            return "Your inventory is managed in the Inventory tab. You can add items manually or by scanning receipts and barcodes. Swipe left on an item to compare prices, or right to add it to your shopping list."
        } else if lowercasedMessage.contains("hello") || lowercasedMessage.contains("hi") {
            return "Hello! How can I help you with Snaptrackr today?"
        } else if lowercasedMessage.contains("thank") {
            return "You're welcome! Is there anything else I can help you with?"
        } else {
            return "I'm not sure I understand. Would you like to know about scanning barcodes, tracking spending, finding best prices, or managing your inventory?"
        }
    }
}

// Chat message model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
}

// Extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// Custom shape for rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ChatbotBubble_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all)
            
            ChatbotBubble()
        }
    }
} 