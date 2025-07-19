//
//  BarcodeScannerView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct BarcodeScannerView: View {
    @State private var isShowingScanner = false
    @State private var scannedCode = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
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
                
                Button(action: {
                    isShowingScanner = true
                }) {
                    Label("Start Scanning", systemImage: "camera.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                
                if !scannedCode.isEmpty {
                    VStack(spacing: 8) {
                        Text("Last Scanned:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(scannedCode)
                            .font(.monospaced(.body)())
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Scanner")
        }
        .sheet(isPresented: $isShowingScanner) {
            // TODO: Implement actual barcode scanner
            Text("Barcode Scanner Implementation Coming Soon")
                .navigationTitle("Scanner")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isShowingScanner = false
                        }
                    }
                }
        }
    }
}

struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView()
    }
}