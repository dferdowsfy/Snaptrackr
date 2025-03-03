import SwiftUI
import AVFoundation
import Vision
import Combine

@objc class ScannerViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var session = AVCaptureSession()
    @Published var isTorchOn = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    private var captureDevice: AVCaptureDevice?
    private var barcodeRequest: VNDetectBarcodesRequest?
    private var textRequest: VNRecognizeTextRequest?
    
    override init() {
        super.init()
    }
    
    func startScanning(type: ScanType) {
        setupCamera()
        
        switch type {
        case .barcode:
            setupBarcodeScanning()
        case .receipt:
            setupReceiptScanning()
        case .unknown:
            break
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopScanning() {
        session.stopRunning()
    }
    
    func toggleTorch() {
        guard let device = captureDevice else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            isTorchOn = device.torchMode == .on
            device.unlockForConfiguration()
        } catch {
            showError("Could not toggle torch")
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            showError("Camera not available")
            return
        }
        
        captureDevice = device
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.beginConfiguration()
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
        } catch {
            showError("Could not setup camera")
        }
    }
    
    private func setupBarcodeScanning() {
        barcodeRequest = VNDetectBarcodesRequest { [weak self] request, error in
            if let error = error {
                self?.showError("Barcode scanning error: \(error.localizedDescription)")
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation],
                  let barcode = results.first?.payloadStringValue else { return }
            
            DispatchQueue.main.async {
                self?.handleBarcodeScan(barcode)
            }
        }
    }
    
    private func setupReceiptScanning() {
        textRequest = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                self?.showError("Receipt scanning error: \(error.localizedDescription)")
                return
            }
            
            guard let results = request.results as? [VNRecognizedTextObservation] else { return }
            
            let text = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            DispatchQueue.main.async {
                self?.handleReceiptScan(text)
            }
        }
        
        textRequest?.recognitionLevel = .accurate
        textRequest?.usesLanguageCorrection = true
    }
    
    private func handleBarcodeScan(_ barcode: String) {
        // Handle the barcode scan result
        print("Scanned barcode: \(barcode)")
    }
    
    private func handleReceiptScan(_ text: String) {
        // Handle the receipt scan result
        print("Scanned receipt text: \(text)")
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.alertTitle = "Error"
            self?.alertMessage = message
            self?.showAlert = true
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
        
        do {
            if let barcodeRequest = barcodeRequest {
                try imageRequestHandler.perform([barcodeRequest])
            }
            if let textRequest = textRequest {
                try imageRequestHandler.perform([textRequest])
            }
        } catch {
            showError("Image processing error: \(error.localizedDescription)")
        }
    }
} 