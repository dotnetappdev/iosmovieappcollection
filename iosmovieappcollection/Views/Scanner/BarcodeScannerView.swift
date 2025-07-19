//
//  BarcodeScannerView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @StateObject private var scannerService = BarcodeScannerService()
    @StateObject private var imdbService = IMDBService()
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingScanner = false
    @State private var showingManualEntry = false
    @State private var showingMovieDetails = false
    @State private var manualBarcode = ""
    @State private var foundMovie: Movie?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Looking up movie...")
                            .font(.headline)
                    }
                } else {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    
                    VStack(spacing: 16) {
                        Text("Barcode Scanner")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Scan UK DVD barcodes to automatically add movies to your collection")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            showingScanner = true
                        }) {
                            Label("Start Scanning", systemImage: "camera.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        
                        Button(action: {
                            showingManualEntry = true
                        }) {
                            Label("Enter Barcode Manually", systemImage: "keyboard")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    if !scannerService.scannedCode.isEmpty {
                        VStack(spacing: 8) {
                            Text("Last Scanned:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(scannerService.scannedCode)
                                .font(.monospaced(.body)())
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            Button("Look up Movie") {
                                lookupMovie(barcode: scannerService.scannedCode)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                    
                    if !appSettings.isAPIConfigured {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Configure IMDB API in Settings to auto-fetch movie details")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Scanner")
        }
        .fullScreenCover(isPresented: $showingScanner) {
            CameraScannerView(scannerService: scannerService) { barcode in
                showingScanner = false
                lookupMovie(barcode: barcode)
            }
        }
        .alert("Enter Barcode", isPresented: $showingManualEntry) {
            TextField("Barcode", text: $manualBarcode)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) { }
            Button("Lookup") {
                if !manualBarcode.isEmpty {
                    scannerService.processManualBarcode(manualBarcode)
                    lookupMovie(barcode: manualBarcode)
                    manualBarcode = ""
                }
            }
        } message: {
            Text("Enter the barcode number manually")
        }
        .sheet(item: $foundMovie) { movie in
            ScannedMovieDetailView(movie: movie) {
                foundMovie = nil
            }
        }
    }
    
    private func lookupMovie(barcode: String) {
        guard appSettings.isAPIConfigured else {
            errorMessage = "Please configure IMDB API in Settings first"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // For demo purposes, we'll search by a common movie title
                // In a real app, you'd have a barcode-to-movie database
                let searchTitle = "Matrix" // This would be determined by barcode lookup
                
                let (movie, _) = try await imdbService.searchAndCreateMovie(
                    title: searchTitle,
                    apiKey: appSettings.imdbAPIKey,
                    baseURL: appSettings.imdbAPIBaseURL
                )
                
                movie.barcode = barcode
                
                await MainActor.run {
                    foundMovie = movie
                    isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct CameraScannerView: View {
    let scannerService: BarcodeScannerService
    let onBarcodeScanned: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    @State private var showingManualEntry = false
    @State private var manualBarcode = ""
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            if let previewLayer = previewLayer {
                CameraPreviewView(previewLayer: previewLayer)
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView("Initializing Camera...")
                        .foregroundColor(.white)
                }
            }
            
            ScannerOverlayView(
                onManualEntry: {
                    showingManualEntry = true
                },
                onFlashlightToggle: {
                    scannerService.toggleFlashlight()
                }
            )
            
            VStack {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .onAppear {
            setupCamera()
        }
        .onDisappear {
            scannerService.stopScanning()
        }
        .alert("Enter Barcode", isPresented: $showingManualEntry) {
            TextField("Barcode", text: $manualBarcode)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) { }
            Button("Done") {
                if !manualBarcode.isEmpty {
                    onBarcodeScanned(manualBarcode)
                    manualBarcode = ""
                }
            }
        }
    }
    
    private func setupCamera() {
        Task {
            do {
                let layer = try await scannerService.setupScanner(delegate: ScannerDelegate { barcode in
                    onBarcodeScanned(barcode)
                })
                
                await MainActor.run {
                    previewLayer = layer
                    scannerService.startScanning()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

class ScannerDelegate: BarcodeScannerService.BarcodeScannerDelegate {
    let onBarcode: (String) -> Void
    
    init(onBarcode: @escaping (String) -> Void) {
        self.onBarcode = onBarcode
    }
    
    func didScanBarcode(_ code: String, type: AVMetadataObject.ObjectType) {
        onBarcode(code)
    }
    
    func didFailWithError(_ error: BarcodeScannerService.ScannerError) {
        print("Scanner error: \(error)")
    }
}

struct ScannedMovieDetailView: View {
    let movie: Movie
    let onDismiss: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @State private var userRating = 5
    @State private var isWanted = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Movie header
                    HStack(alignment: .top, spacing: 16) {
                        AsyncImage(url: URL(string: movie.posterURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "film.fill")
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 120, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if let year = movie.year {
                                Text(String(year))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let genre = movie.genre {
                                Text(genre)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            
                            if let director = movie.director {
                                Text("Dir: \(director)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // User preferences
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add to Collection")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Toggle("Add to Wishlist", isOn: $isWanted)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Your Rating")
                                Spacer()
                                Picker("Rating", selection: $userRating) {
                                    ForEach(1...10, id: \.self) { rating in
                                        Text("\(rating)")
                                            .tag(rating)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Movie details
                    if let plot = movie.plot {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Plot")
                                .font(.headline)
                            Text(plot)
                                .font(.body)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Add Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveMovie()
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
    
    private func saveMovie() {
        isSaving = true
        
        movie.isWanted = isWanted
        movie.userRating = userRating
        
        modelContext.insert(movie)
        
        try? modelContext.save()
        
        onDismiss()
    }
}

struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView()
            .environmentObject(AppSettings())
    }
}