//
//  BarcodeScannerView.swift
//  iosmovieappcollection
//
//  Enhanced barcode scanning using CodeScanner
//

import SwiftUI
import SwiftData
import CodeScanner

struct BarcodeScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingScanner = false
    @State private var scannedCode: String = ""
    @State private var isLoading = false
    @State private var foundMovie: MovieAPIResponse?
    @State private var errorMessage: String?
    
    private let movieService = MovieService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !scannedCode.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("Scanned Code")
                            .font(.headline)
                        
                        Text(scannedCode)
                            .font(.monospaced(.body)())
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        if isLoading {
                            ProgressView("Searching for movie...")
                        } else if let movie = foundMovie {
                            MovieFoundView(movie: movie) {
                                addMovieToCollection(movie)
                            }
                        } else if let error = errorMessage {
                            VStack {
                                Text("Movie Not Found")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Add Manually") {
                                    addManualMovie()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        
                        Button("Scan Another") {
                            resetScan()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 64))
                            .foregroundColor(.blue)
                        
                        Text("Scan Movie Barcode")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Scan the barcode on your movie DVD, Blu-ray, or product packaging to add it to your collection.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Start Scanning") {
                            isShowingScanner = true
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Supported Formats:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• UPC-A, UPC-E")
                                Text("• EAN-8, EAN-13")
                                Text("• Code 128")
                                Text("• QR Codes")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(
                    codeTypes: [.upce, .upca, .ean8, .ean13, .code128, .qr],
                    simulatedData: "1234567890123",
                    completion: handleScan
                )
            }
        }
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            scannedCode = result.string
            searchMovieByBarcode(result.string)
        case .failure(let error):
            errorMessage = "Scanning failed: \(error.localizedDescription)"
        }
    }
    
    private func searchMovieByBarcode(_ barcode: String) {
        isLoading = true
        errorMessage = nil
        foundMovie = nil
        
        // Note: In a real app, you would need a service that can convert barcodes to movie IDs
        // For demo purposes, we'll simulate this with mock data
        Task {
            await MainActor.run {
                // Simulate a delay for searching
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isLoading = false
                    
                    // For demo purposes, assign mock movies based on barcode patterns
                    let mockMovies = movieService.getMockMovies()
                    if let movie = mockMovies.first(where: { "\($0.id)" == String(barcode.suffix(1)) }) {
                        self.foundMovie = movie
                    } else if !mockMovies.isEmpty {
                        // Use first mock movie if no pattern match
                        self.foundMovie = mockMovies[0]
                    } else {
                        self.errorMessage = "No movie found for this barcode. You can add it manually to your collection."
                    }
                }
            }
        }
    }
    
    private func addMovieToCollection(_ movieResponse: MovieAPIResponse) {
        withAnimation {
            let movie = movieResponse.toMovie()
            movie.barcode = scannedCode
            modelContext.insert(movie)
            dismiss()
        }
    }
    
    private func addManualMovie() {
        withAnimation {
            let movie = Movie(
                id: Int.random(in: 10000...99999),
                title: "Unknown Movie",
                overview: "Movie added via barcode scan: \(scannedCode)",
                posterPath: nil,
                releaseDate: DateFormatter.shortDate.string(from: Date()),
                voteAverage: 0.0,
                barcode: scannedCode
            )
            modelContext.insert(movie)
            dismiss()
        }
    }
    
    private func resetScan() {
        scannedCode = ""
        foundMovie = nil
        errorMessage = nil
        isLoading = false
    }
}

struct MovieFoundView: View {
    let movie: MovieAPIResponse
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Movie Found!")
                .font(.headline)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Released: \(movie.formattedReleaseDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.subheadline)
                }
                
                Text(movie.overview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Button("Add to Collection") {
                onAdd()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

#Preview {
    BarcodeScannerView()
        .modelContainer(for: Movie.self, inMemory: true)
}