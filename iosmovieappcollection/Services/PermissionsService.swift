//
//  PermissionsService.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import Foundation
import AVFoundation
import Photos
import SwiftUI

// MARK: - Permissions Service
@MainActor
class PermissionsService: ObservableObject {
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryPermissionStatus: PHAuthorizationStatus = .notDetermined
    
    init() {
        updatePermissionStatuses()
    }
    
    // MARK: - Status Updates
    func updatePermissionStatuses() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoLibraryPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }
    
    // MARK: - Camera Permissions
    func requestCameraPermission() async -> Bool {
        let status = await AVCaptureDevice.requestAccess(for: .video)
        await MainActor.run {
            cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        }
        return status
    }
    
    var cameraPermissionDescription: String {
        switch cameraPermissionStatus {
        case .notDetermined:
            return "Camera access not requested"
        case .denied:
            return "Camera access denied"
        case .restricted:
            return "Camera access restricted"
        case .authorized:
            return "Camera access granted"
        @unknown default:
            return "Unknown camera status"
        }
    }
    
    // MARK: - Photo Library Permissions
    func requestPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        await MainActor.run {
            photoLibraryPermissionStatus = status
        }
        
        switch status {
        case .authorized, .limited:
            return true
        default:
            return false
        }
    }
    
    var photoLibraryPermissionDescription: String {
        switch photoLibraryPermissionStatus {
        case .notDetermined:
            return "Photo library access not requested"
        case .denied:
            return "Photo library access denied"
        case .restricted:
            return "Photo library access restricted"
        case .authorized:
            return "Photo library access granted"
        case .limited:
            return "Limited photo library access"
        @unknown default:
            return "Unknown photo library status"
        }
    }
    
    // MARK: - Combined Status
    var allPermissionsGranted: Bool {
        return cameraPermissionStatus == .authorized &&
               (photoLibraryPermissionStatus == .authorized || photoLibraryPermissionStatus == .limited)
    }
    
    func requestAllPermissions() async -> Bool {
        let cameraGranted = await requestCameraPermission()
        let photoGranted = await requestPhotoLibraryPermission()
        
        return cameraGranted && photoGranted
    }
    
    // MARK: - Settings Navigation
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Permissions View
struct PermissionsView: View {
    @StateObject private var permissionsService = PermissionsService()
    @State private var isRequestingPermissions = false
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Permissions Required")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("This app needs access to your camera and photo library to scan barcodes and save movie posters.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 16) {
                PermissionRow(
                    icon: "camera.fill",
                    title: "Camera",
                    description: "Required for barcode scanning",
                    status: permissionsService.cameraPermissionStatus == .authorized ? .granted : .notGranted
                )
                
                PermissionRow(
                    icon: "photo.fill",
                    title: "Photo Library",
                    description: "Optional: Save movie posters to photo albums",
                    status: permissionsService.photoLibraryPermissionStatus == .authorized || permissionsService.photoLibraryPermissionStatus == .limited ? .granted : .notGranted
                )
            }
            
            VStack(spacing: 12) {
                if permissionsService.allPermissionsGranted {
                    Button(action: onComplete) {
                        Label("Continue", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                } else {
                    Button(action: requestPermissions) {
                        HStack {
                            if isRequestingPermissions {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "hand.raised.fill")
                            }
                            Text(isRequestingPermissions ? "Requesting..." : "Grant Permissions")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    }
                    .disabled(isRequestingPermissions)
                    
                    if permissionsService.cameraPermissionStatus == .denied || permissionsService.photoLibraryPermissionStatus == .denied {
                        Button(action: permissionsService.openAppSettings) {
                            Label("Open Settings", systemImage: "gear")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                
                Button("Skip Photo Library") {
                    if permissionsService.cameraPermissionStatus == .authorized {
                        onComplete()
                    } else {
                        Task {
                            await permissionsService.requestCameraPermission()
                            if permissionsService.cameraPermissionStatus == .authorized {
                                onComplete()
                            }
                        }
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .onAppear {
            permissionsService.updatePermissionStatuses()
        }
    }
    
    private func requestPermissions() {
        isRequestingPermissions = true
        
        Task {
            await permissionsService.requestAllPermissions()
            await MainActor.run {
                isRequestingPermissions = false
                if permissionsService.allPermissionsGranted {
                    onComplete()
                }
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionStatus
    
    enum PermissionStatus {
        case granted
        case notGranted
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(status == .granted ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(status == .granted ? .white : .gray)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    if status == .granted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView {
            print("Permissions complete")
        }
    }
}