import SwiftUI
import AVFoundation
import Vision

struct AddItemsView: View {
    @State private var isShowingCamera = false
    @State private var scannedImage: UIImage?
    @State private var scannedBarcode: String?
    @State private var scanType: ScanType = .unknown
    @State private var processingResult: String?
    @State private var showReceiptScanner = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Page title
                Text("Add Items")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Spacer()
                    .frame(height: 40)
                
                // Main scan button
                Button(action: {
                    isShowingCamera = true
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                        
                        Text("Scan Barcode")
                            .font(.headline)
                    }
                    .padding(40)
                    .foregroundColor(.white)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                }
                
                // Receipt scanner button
                Button(action: {
                    showReceiptScanner = true
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 60))
                        
                        Text("Scan Receipt")
                            .font(.headline)
                    }
                    .padding(40)
                    .foregroundColor(.white)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                }
                
                if let result = processingResult {
                    Text(result)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $isShowingCamera) {
            ImagePicker(isPresented: $isShowingCamera, image: $scannedImage)
                .edgesIgnoringSafeArea(.all)
                .onDisappear {
                    if let image = scannedImage {
                        // Try to detect barcodes first
                        detectBarcode(in: image) { barcode in
                            if let barcode = barcode {
                                scannedBarcode = barcode
                                scanType = .barcode
                                processScannedData()
                            } else {
                                // If no barcode found, treat as receipt
                                scanType = .receipt
                                processScannedData()
                            }
                        }
                    }
                }
        }
        .sheet(isPresented: $showReceiptScanner) {
            ReceiptProcessingView()
        }
    }
    
    func processScannedData() {
        // Processing logic based on scan type
        switch scanType {
        case .barcode:
            if let barcode = scannedBarcode {
                processingResult = "Processing barcode: \(barcode)"
                
                // API call would go here
                APIService.shared.queryPerplexityForBarcode(barcode) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            processingResult = "Product found: \(data)"
                        case .failure(let error):
                            processingResult = "Error: \(error.localizedDescription)"
                        }
                    }
                }
            }
        case .receipt:
            if let image = scannedImage {
                processingResult = "Processing receipt image..."
                
                // API call would go here
                APIService.shared.processReceiptWithGemini(image) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            processingResult = "Receipt items: \(data)"
                        case .failure(let error):
                            processingResult = "Error: \(error.localizedDescription)"
                        }
                    }
                }
            }
        case .unknown:
            processingResult = "Unknown scan type"
        }
    }
    
    // Detect barcode in image
    private func detectBarcode(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNDetectBarcodesRequest { request, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation], !results.isEmpty else {
                completion(nil)
                return
            }
            
            // Return the first barcode found
            if let barcode = results.first?.payloadStringValue {
                completion(barcode)
            } else {
                completion(nil)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            completion(nil)
        }
    }
}

// Camera Scanner View
struct CameraScannerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var scanType: ScanType
    @Binding var scannedImage: UIImage?
    @Binding var scannedBarcode: String?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraViewController = UIImagePickerController()
        cameraViewController.sourceType = .camera
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, scanType: $scanType, scannedImage: $scannedImage, scannedBarcode: $scannedBarcode)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var isPresented: Bool
        @Binding var scanType: ScanType
        @Binding var scannedImage: UIImage?
        @Binding var scannedBarcode: String?
        
        init(isPresented: Binding<Bool>, scanType: Binding<ScanType>, scannedImage: Binding<UIImage?>, scannedBarcode: Binding<String?>) {
            self._isPresented = isPresented
            self._scanType = scanType
            self._scannedImage = scannedImage
            self._scannedBarcode = scannedBarcode
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                scannedImage = image
                
                // Detect if the image contains a barcode
                detectBarcode(in: image) { barcode in
                    if let barcode = barcode {
                        self.scanType = .barcode
                        self.scannedBarcode = barcode
                    } else {
                        self.scanType = .receipt
                    }
                    self.isPresented = false
                }
            } else {
                scanType = .unknown
                isPresented = false
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isPresented = false
        }
        
        // Detect barcode in image
        private func detectBarcode(in image: UIImage, completion: @escaping (String?) -> Void) {
            guard let cgImage = image.cgImage else {
                completion(nil)
                return
            }
            
            let request = VNDetectBarcodesRequest { request, error in
                guard error == nil else {
                    completion(nil)
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation], !results.isEmpty else {
                    completion(nil)
                    return
                }
                
                // Return the first barcode found
                if let barcode = results.first?.payloadStringValue {
                    completion(barcode)
                } else {
                    completion(nil)
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                completion(nil)
            }
        }
    }
}

#Preview {
    AddItemsView()
} 