import SwiftUI
import Vision
import VisionKit

// Define the ScannerReceiptItem struct at the top level to avoid ambiguity
struct ScannerReceiptItem {
    var name: String
    var price: Double
}

struct ReceiptProcessingView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    
    @State private var scannedImage: UIImage?
    @State private var recognizedText: String = ""
    @State private var extractedItems: [ScannerReceiptItem] = []
    @State private var isProcessing = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?
    @State private var receiptDate = Date()
    @State private var storeName = ""
    @State private var totalAmount: Double = 0.0
    
    // For document scanner
    @State private var showDocumentScanner = false
    @State private var showScanOptions = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 68/255, green: 36/255, blue: 164/255).opacity(0.8),
                        Color(red: 84/255, green: 212/255, blue: 228/255).opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Text("Receipt Scanner")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        // Receipt image preview
                        if let scannedImage = scannedImage {
                            Image(uiImage: scannedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding(.horizontal)
                        } else {
                            // Placeholder
                            ZStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                
                                VStack {
                                    Image(systemName: "doc.text.viewfinder")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                    
                                    Text("Scan a receipt to get started")
                                        .foregroundColor(.white)
                                        .padding(.top, 8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Scan button with options
                        ZStack {
                            // Main scan button
                            Button(action: {
                                withAnimation(.spring()) {
                                    showScanOptions.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: showScanOptions ? "xmark" : "doc.text.viewfinder")
                                    Text(showScanOptions ? "Close" : "Scan Receipt")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(Color(red: 68/255, green: 36/255, blue: 164/255))
                                .cornerRadius(10)
                                .shadow(radius: 3)
                            }
                            .padding(.horizontal)
                            
                            // Scan options
                            if showScanOptions {
                                VStack(spacing: 10) {
                                    // Camera option
                                    Button(action: {
                                        showDocumentScanner = true
                                        withAnimation {
                                            showScanOptions = false
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "camera.viewfinder")
                                            Text("Camera")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                    
                                    // Photo library option
                                    Button(action: {
                                        // Photo library action would go here
                                        withAnimation {
                                            showScanOptions = false
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "photo.on.rectangle")
                                            Text("Photo Library")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                    
                                    // Manual entry option
                                    Button(action: {
                                        extractedItems = [ScannerReceiptItem(name: "", price: 0.0)]
                                        withAnimation {
                                            showScanOptions = false
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "keyboard")
                                            Text("Manual Entry")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.top, 60)
                                .padding(.horizontal)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .zIndex(1)
                            }
                        }
                        
                        // Receipt details form
                        if !extractedItems.isEmpty {
                            receiptDetailsForm
                        }
                    }
                    .padding(.bottom, 30)
                }
                
                // Processing overlay
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(2.0)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            
                            Text("Processing receipt...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(30)
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Success!"),
                    message: Text("Receipt data has been saved to your Google Sheet."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .sheet(isPresented: $showDocumentScanner) {
                DocumentScannerView(scannedImage: $scannedImage, recognizedText: $recognizedText, isProcessing: $isProcessing)
                    .onDisappear {
                        if let image = scannedImage {
                            processReceipt(image: image)
                        }
                    }
            }
        }
    }
    
    // Receipt details form
    private var receiptDetailsForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Form header
            Text("Receipt Details")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            // Store name
            VStack(alignment: .leading) {
                Text("Store Name")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("Enter store name", text: $storeName)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            // Date picker
            VStack(alignment: .leading) {
                Text("Receipt Date")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                DatePicker("", selection: $receiptDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .accentColor(.white)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            // Total amount
            VStack(alignment: .leading) {
                Text("Total Amount")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("Enter total amount", value: $totalAmount, formatter: currencyFormatter)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            // Extracted items list
            VStack(alignment: .leading) {
                Text("Extracted Items")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                ForEach(extractedItems.indices, id: \.self) { index in
                    HStack {
                        TextField("Item name", text: $extractedItems[index].name)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        
                        TextField("Price", value: $extractedItems[index].price, formatter: currencyFormatter)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                }
                
                // Add item button
                Button(action: {
                    extractedItems.append(ScannerReceiptItem(name: "", price: 0.0))
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            // Save button
            Button(action: {
                saveReceiptData()
            }) {
                Text("Save Receipt Data")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color(red: 68/255, green: 36/255, blue: 164/255))
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .padding(.vertical)
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
        .padding()
    }
    
    // Currency formatter
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }
    
    // Process receipt image
    private func processReceipt(image: UIImage) {
        isProcessing = true
        
        // Convert to receipt items (simulated for now)
        // In a real app, this would use Vision framework for text recognition
        // and then parse the text to extract items and prices
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Extract store name from recognized text (simplified example)
            if let storeName = extractStoreName(from: recognizedText) {
                self.storeName = storeName
            }
            
            // Extract total from recognized text (simplified example)
            if let total = extractTotal(from: recognizedText) {
                self.totalAmount = total
            }
            
            // Extract items from recognized text (simplified example)
            self.extractedItems = extractItems(from: recognizedText)
            
            self.isProcessing = false
        }
    }
    
    // Save receipt data to Google Sheets
    private func saveReceiptData() {
        guard !extractedItems.isEmpty, !storeName.isEmpty else {
            errorMessage = "Please add at least one item and store name"
            return
        }
        
        isProcessing = true
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: receiptDate)
        
        // Convert to GoogleSheetsService.ReceiptItem format
        let items = extractedItems.map { item in
            GoogleSheetsService.ReceiptItem(
                item: item.name,
                price: item.price,
                date: dateString,
                emailID: authManager.currentUser?.email ?? "unknown@example.com"
            )
        }
        
        // Save to Google Sheets
        GoogleSheetsService.shared.writeReceiptData(items: items) { result in
            DispatchQueue.main.async {
                isProcessing = false
                
                switch result {
                case .success:
                    showSuccessAlert = true
                case .failure(let error):
                    errorMessage = "Failed to save receipt data: \(error)"
                }
            }
        }
    }
    
    // Helper functions for text extraction (simplified examples)
    private func extractStoreName(from text: String) -> String? {
        // In a real app, this would use more sophisticated NLP techniques
        // For now, just return a placeholder
        return "Grocery Store"
    }
    
    private func extractTotal(from text: String) -> Double? {
        // In a real app, this would use regex or NLP to find the total
        // For now, just return a placeholder
        return 45.67
    }
    
    private func extractItems(from text: String) -> [ScannerReceiptItem] {
        // In a real app, this would parse the receipt text to identify items and prices
        // For now, just return placeholder items
        return [
            ScannerReceiptItem(name: "Milk", price: 3.99),
            ScannerReceiptItem(name: "Bread", price: 2.49),
            ScannerReceiptItem(name: "Eggs", price: 4.99)
        ]
    }
}

// Document scanner view using VisionKit
struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedImage: UIImage?
    @Binding var recognizedText: String
    @Binding var isProcessing: Bool
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        return documentCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // Get the first page
            if scan.pageCount > 0 {
                let image = scan.imageOfPage(at: 0)
                parent.scannedImage = image
                
                // Perform text recognition
                recognizeText(in: image)
            }
            
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document camera error: \(error)")
            controller.dismiss(animated: true)
        }
        
        private func recognizeText(in image: UIImage) {
            parent.isProcessing = true
            
            guard let cgImage = image.cgImage else {
                parent.isProcessing = false
                return
            }
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Text recognition error: \(error)")
                    DispatchQueue.main.async {
                        self.parent.isProcessing = false
                    }
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    DispatchQueue.main.async {
                        self.parent.isProcessing = false
                    }
                    return
                }
                
                // Process the recognized text
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                DispatchQueue.main.async {
                    self.parent.recognizedText = recognizedText
                    self.parent.isProcessing = false
                }
            }
            
            // Configure the text recognition request
            request.recognitionLevel = .accurate
            
            do {
                try requestHandler.perform([request])
            } catch {
                print("Unable to perform text recognition: \(error)")
                DispatchQueue.main.async {
                    self.parent.isProcessing = false
                }
            }
        }
    }
}

struct ReceiptProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptProcessingView()
            .environmentObject(AuthManager.shared)
    }
} 
