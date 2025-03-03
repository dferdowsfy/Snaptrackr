import SwiftUI
import SwiftData

struct ItemDetailView: View {
    var item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let title = item.title {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            } else {
                Text("Item Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Text("Added: \(item.timestamp, formatter: itemFormatter)")
                .foregroundColor(.secondary)
            
            HStack {
                Text("Price:")
                    .fontWeight(.semibold)
                Spacer()
                Text("$\(String(format: "%.2f", item.price))")
            }
            .padding(.vertical, 5)
            
            HStack {
                Text("Quantity:")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(String(format: "%.1f", item.quantity))")
            }
            .padding(.vertical, 5)
            
            if let category = item.category {
                HStack {
                    Text("Category:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(category)
                }
                .padding(.vertical, 5)
            }
            
            if let notes = item.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes:")
                        .fontWeight(.semibold)
                    Text(notes)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.vertical, 5)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Item Details")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}() 
