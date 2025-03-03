import SwiftUI
import AVFoundation

struct ScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var scannerViewModel = ScannerViewModel()
    let scanType: ScanType
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(session: scannerViewModel.session)
                .ignoresSafeArea()
            
            // Scanning overlay
            VStack {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text(scanType == .barcode ? "Scan Barcode" : "Scan Receipt")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        scannerViewModel.toggleTorch()
                    }) {
                        Image(systemName: scannerViewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .background(Color.black.opacity(0.5))
                
                Spacer()
                
                // Scanning frame
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: scanType == .barcode ? 280 : 300, height: scanType == .barcode ? 160 : 400)
                    .overlay(
                        scanType == .barcode ?
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5)) :
                        Image(systemName: "doc.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                    )
                
                Spacer()
                
                // Instructions
                Text(scanType == .barcode ? "Position the barcode within the frame" : "Position the receipt within the frame")
                    .font(.callout)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                    .padding(.bottom)
            }
        }
        .onAppear {
            scannerViewModel.startScanning(type: scanType)
        }
        .onDisappear {
            scannerViewModel.stopScanning()
        }
        .alert(isPresented: $scannerViewModel.showAlert) {
            Alert(
                title: Text(scannerViewModel.alertTitle),
                message: Text(scannerViewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// Camera preview view
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
} 