//
//  BarcodeScannerService.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import Foundation
import AVFoundation
import SwiftUI

// MARK: - Barcode Scanner Service
@MainActor
class BarcodeScannerService: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var scannedCode: String = ""
    @Published var errorMessage: String?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var delegate: BarcodeScannerDelegate?
    
    enum ScannerError: LocalizedError {
        case cameraUnavailable
        case permissionDenied
        case configurationFailed
        
        var errorDescription: String? {
            switch self {
            case .cameraUnavailable:
                return "Camera is not available"
            case .permissionDenied:
                return "Camera permission denied"
            case .configurationFailed:
                return "Failed to configure camera"
            }
        }
    }
    
    // MARK: - Scanner Delegate
    protocol BarcodeScannerDelegate: AnyObject {
        func didScanBarcode(_ code: String, type: AVMetadataObject.ObjectType)
        func didFailWithError(_ error: ScannerError)
    }
    
    // MARK: - Setup Methods
    func setupScanner(delegate: BarcodeScannerDelegate?) async throws -> AVCaptureVideoPreviewLayer {
        self.delegate = delegate
        
        // Check camera availability
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            throw ScannerError.cameraUnavailable
        }
        
        // Check permissions
        let permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch permissionStatus {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if !granted {
                throw ScannerError.permissionDenied
            }
        case .denied, .restricted:
            throw ScannerError.permissionDenied
        case .authorized:
            break
        @unknown default:
            throw ScannerError.permissionDenied
        }
        
        // Configure capture session
        let captureSession = AVCaptureSession()
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            throw ScannerError.configurationFailed
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            throw ScannerError.configurationFailed
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Support multiple barcode formats commonly used for DVDs
            metadataOutput.metadataObjectTypes = [
                .ean8,
                .ean13,
                .pdf417,
                .qr,
                .code128,
                .code39,
                .code93,
                .upce
            ]
        } else {
            throw ScannerError.configurationFailed
        }
        
        // Create preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        self.captureSession = captureSession
        self.previewLayer = previewLayer
        
        return previewLayer
    }
    
    func startScanning() {
        guard let captureSession = captureSession else { return }
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
        
        isScanning = true
        errorMessage = nil
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        isScanning = false
    }
    
    func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = device.isTorchActive ? .off : .on
            device.unlockForConfiguration()
        } catch {
            print("Failed to toggle flashlight: \(error)")
        }
    }
    
    // MARK: - Manual Barcode Input
    func processManualBarcode(_ code: String) {
        scannedCode = code
        delegate?.didScanBarcode(code, type: .ean13) // Assume EAN13 for manual input
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension BarcodeScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Audio feedback (if enabled in settings)
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        scannedCode = stringValue
        delegate?.didScanBarcode(stringValue, type: readableObject.type)
        
        // Stop scanning to prevent multiple scans
        stopScanning()
    }
}

// MARK: - Camera Preview View
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.layer.bounds
    }
}

// MARK: - Scanner Overlay View
struct ScannerOverlayView: View {
    let onManualEntry: () -> Void
    let onFlashlightToggle: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            
            VStack {
                Spacer()
                
                // Scanning area frame
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 280, height: 200)
                    .overlay(
                        VStack {
                            Text("Position barcode within frame")
                                .foregroundColor(.white)
                                .font(.caption)
                                .padding(.top, -40)
                            
                            Spacer()
                            
                            // Scanning line animation
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 2)
                                .opacity(0.8)
                        }
                    )
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 30) {
                    Button(action: onFlashlightToggle) {
                        VStack {
                            Image(systemName: "flashlight.on.fill")
                                .font(.title2)
                            Text("Flash")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                    }
                    
                    Button(action: onManualEntry) {
                        VStack {
                            Image(systemName: "keyboard")
                                .font(.title2)
                            Text("Manual")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}