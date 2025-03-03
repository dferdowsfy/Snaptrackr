import SwiftUI

struct ScanOptionsView: View {
    @Binding var showScanOptions: Bool
    @Binding var showBarcodeScanner: Bool
    @Binding var showReceiptScanner: Bool
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    showScanOptions = false
                    showBarcodeScanner = true
                }) {
                    Label("Scan Barcode", systemImage: "barcode.viewfinder")
                }
                
                Button(action: {
                    showScanOptions = false
                    showReceiptScanner = true
                }) {
                    Label("Scan Receipt", systemImage: "doc.viewfinder")
                }
            }
            .navigationTitle("Add Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showScanOptions = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
} 